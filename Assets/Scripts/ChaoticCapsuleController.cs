using UnityEngine;

public class ChaoticCapsuleController : MonoBehaviour
{
[Tooltip("This is the first capsule")][Header("Capsule Settings")][SerializeField]private MeshRenderer capsule1;

[SerializeField]private float speed1 = 0.2f;

[Range(0f, 10f)][Tooltip("Speed of capsule 2")][SerializeField][Header("Capsule Settings #2")]private float speed2 = 0.5f;

[SerializeField][Tooltip("Material for capsule")]private Material capsuleMaterial;

[Header("Miscellaneous")][SerializeField]private string debugText;

    // Method chaos
    void Start()
    {
        Debug.Log("Starting...");
    }

[SerializeField]private bool isActive = true;

[Tooltip("This boolean does something")][SerializeField][Header("Boolean Zone")]private bool useCapsules;

    void Update()
    {
        if (isActive)
        {
            float speed = Input.GetKey(KeyCode.Space) ? speed2 : speed1;
            capsule1.transform.Rotate(Vector3.up * speed);
        }
    }
}
