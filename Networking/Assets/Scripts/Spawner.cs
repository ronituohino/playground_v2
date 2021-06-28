using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Mirror;

public class Spawner : NetworkBehaviour
{
    [SerializeField] float spawnInterval;

    [SerializeField] RectTransform parent;
    [SerializeField] RectTransform rect;

    [SerializeField] GameObject g;

    float timer = 0f;

    // Update is called once per frame
    void Update()
    {
        if (NetworkServer.active)
        {
            timer += Time.deltaTime;

            if (timer >= spawnInterval)
            {
                timer = 0f;
                Spawn();
            }
        }
    }

    void Spawn()
    {
        float xPos = Random.Range(rect.anchoredPosition.x - rect.sizeDelta.x / 2f, rect.anchoredPosition.x + rect.sizeDelta.x / 2f);
        float yPos = Random.Range(rect.anchoredPosition.y - rect.sizeDelta.y / 2f, rect.anchoredPosition.y + rect.sizeDelta.y / 2f);

        GameObject gObj = Instantiate(g);

        gObj.GetComponent<MirrorHierarchyNetworkBehaviour>().hierarchyPosition = new MirrorHierarchyNetworkBehaviour.HierarchyPosition
        (
            parent.GetComponent<NetworkIdentity>().netId, //Make sure parent object has NetworkIdentity attached to it!
            new Vector2(xPos, yPos),
            0f,
            new Vector3(1, 1, 1)
        );

        NetworkServer.Spawn(gObj);
    }
}
