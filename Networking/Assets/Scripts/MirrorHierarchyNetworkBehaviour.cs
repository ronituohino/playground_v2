using System.Collections;
using UnityEngine;
using Mirror;
using Steamworks;

public class MirrorHierarchyNetworkBehaviour : NetworkBehaviour
{
    [SyncVar(hook = nameof(UpdateTransform))]
    public HierarchyPosition hierarchyPosition;

    //netId identifies obejcts in a network, set netId of parent
    //When setting object parent, the object's transform is changed, 
    //reset position rotation and scale
    public struct HierarchyPosition
    {
        public uint netId;

        public Vector2 position;
        public float rotation;
        public Vector2 scale;

        public HierarchyPosition(uint netId, Vector2 position, float rotation, Vector2 scale)
        {
            this.netId = netId;
            this.position = position;
            this.rotation = rotation;
            this.scale = scale;
        }
    }

    void UpdateTransform(HierarchyPosition oldValue, HierarchyPosition newValue)
    {
        transform.SetParent(NetworkIdentity.spawned[newValue.netId].transform);

        transform.localPosition = newValue.position;
        transform.rotation = Quaternion.Euler(0, 0, newValue.rotation);
        transform.localScale = new Vector3(newValue.scale.x, newValue.scale.y, 1);
    }

    //Attach this to spawner:

    /*
     g.GetComponent<>().hierarchyPosition = new MirrorHierarchyNetworkBehaviour.HierarchyPosition
     (
        parent.GetComponent<NetworkIdentity>().netId,
        pos: vec2,
        rot: float,
        scale: vec2
     );
    */
}