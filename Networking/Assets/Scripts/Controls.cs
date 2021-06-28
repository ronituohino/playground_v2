using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Mirror;
using TMPro;

public class Controls : MirrorHierarchyNetworkBehaviour
{
    [SerializeField] RectTransform rect;
    [SerializeField] float movementSpeed;

    [SyncVar(hook = nameof(ChangePlayerName))] 
    public string playerName;

    // Update is called once per frame
    void Update()
    {
        if(isLocalPlayer)
        {
            Vector2 movement = Vector2.zero;
            if (Input.GetKey(KeyCode.W))
            {
                movement += new Vector2(0, 1);
            }
            if (Input.GetKey(KeyCode.A))
            {
                movement += new Vector2(-1, 0);
            }
            if (Input.GetKey(KeyCode.S))
            {
                movement += new Vector2(0, -1);
            }
            if (Input.GetKey(KeyCode.D))
            {
                movement += new Vector2(1, 0);
            }

            movement = movement.normalized * movementSpeed;
            rect.anchoredPosition += movement;
        }
    }

    void ChangePlayerName(string oldValue, string newValue)
    {
        GetComponentInChildren<TextMeshProUGUI>().text = newValue;
    }
}
