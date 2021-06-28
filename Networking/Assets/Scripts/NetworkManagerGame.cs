using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Mirror;
using UnityEngine.SceneManagement;
using TMPro;

public class NetworkManagerGame : NetworkManager
{
    [Header("Custom")]

    [SerializeField] GameObject playerObj;
    bool stopping = false;

    new void Start()
    {
        base.Start();

        SceneManager.LoadScene(1, LoadSceneMode.Single);
    }

    public struct CreatePlayer : NetworkMessage
    {
        public string playerName;
    }

    public struct StopPlayerClient : NetworkMessage { }

    [Server]
    public override void OnStartServer()
    {
        NetworkServer.RegisterHandler<CreatePlayer>(OnCreatePlayer);
    }

    [Server]
    void OnCreatePlayer(NetworkConnection conn, CreatePlayer createPlayer)
    {
        GameObject g = Instantiate(playerObj);
        NetworkServer.AddPlayerForConnection(conn, g);

        Controls c = g.GetComponent<Controls>();
        c.hierarchyPosition = new MirrorHierarchyNetworkBehaviour.HierarchyPosition
        (
            GameObject.Find("Players").GetComponent<NetworkIdentity>().netId,
            g.transform.position,
            0f,
            g.transform.localScale
        );

        c.playerName = createPlayer.playerName;
    }

    [Server]
    public override void OnStopServer()
    {
        print("Disconnecting all");
        NetworkServer.SendToAll<StopPlayerClient>(new StopPlayerClient());
    }

    [Server]
    public override void OnServerDisconnect(NetworkConnection conn)
    {
        NetworkServer.RemovePlayerForConnection(conn, true);
        print("Someone disconnected");
    }



    //Connecting
    [Client]
    public override void OnClientConnect(NetworkConnection conn)
    {
        NetworkClient.RegisterHandler<StopPlayerClient>(ForceCloseByServer);
        StartCoroutine(StartGame(conn));
    }

    [Client]
    IEnumerator StartGame(NetworkConnection conn)
    {
        AsyncOperation async = SceneManager.LoadSceneAsync(2, LoadSceneMode.Additive);
        yield return async;

        StartCoroutine(UnloadAssets(1));

        ClientScene.Ready(conn);

        CreatePlayer msg = new CreatePlayer();
        msg.playerName = ":)";
        conn.Send<CreatePlayer>(msg);
    }

    IEnumerator UnloadAssets(int sceneIndex)
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync(sceneIndex);
        yield return async;

        Resources.UnloadUnusedAssets();
        stopping = false;
    }



    //Disconnecting
    [Client]
    public void ForceCloseByServer(NetworkConnection conn, StopPlayerClient msg)
    {
        if(!stopping)
        {
            print("Server forced stop client");
            StopClient();
        }
    }

    //Called on all clients, including the host
    public override void OnStopClient()
    {
        if(!stopping)
        {
            print("Stopped");
            StartCoroutine(CloseGame());
        }
    }

    IEnumerator CloseGame()
    {
        stopping = true;

        AsyncOperation async = SceneManager.LoadSceneAsync(1, LoadSceneMode.Additive);
        yield return async;

        StartCoroutine(UnloadAssets(2));
    }
}
