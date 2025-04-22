using UnityEngine;
using System;
using System.Collections.Generic;

public class ExampleBehaviour : MonoBehaviour
{
	// ────────────────────────────────
	// 🟩 ENUMS
	// - Public enums first
	// - Then private enums
	// ────────────────────────────────
	public enum ExampleEnum { OptionA, OptionB, OptionC }
	private enum InternalState { Idle, Working, Complete }

	// ────────────────────────────────
	// 🟩 CONSTANTS
	// - Public before private
	// - consts always before statics
	// ────────────────────────────────
	public const string ExampleSurfaceTag = "ExampleSurface";
	private const float MaxAllowedSpeed = 20f;

	// ────────────────────────────────
	// 🟩 STATIC EVENTS
	// - Ordered by output type:
	//   object → primitive → none
	// ────────────────────────────────
	public static event Action<GameObject> OnEventWithObjectOutput1;
	public static event Action<int> OnEventWithPrimitiveOutput1;
	public static event Action OnEventWithoutOutput1;

	// ────────────────────────────────
	// 🟩 STATIC FIELDS
	// - Public before private
	// - Fields ordered by output type:
	//   object → primitive
	// ────────────────────────────────
	public static int TotalInstances = 0;

	// ────────────────────────────────
	// 🟩 STATIC READONLY
	// - Runtime constants shared by all instances
	// ────────────────────────────────
	private static readonly string internalIdPrefix = "EX-";

	// ────────────────────────────────
	// 🟩 INSTANCE READONLY
	// - Runtime constant unique to each instance
	// ────────────────────────────────
	private readonly string instanceId = System.Guid.NewGuid().ToString();

	// ────────────────────────────────
	// 🟩 INSTANCE EVENTS
	// - Grouped below readonly
	// - Ordered by output type:
	//   object → primitive → none
	// ────────────────────────────────
	public event Action<GameObject> OnEventWithObjectOutput2;
	public event Action<int> OnEventWithPrimitiveOutput2;
	public event Action OnEventWithoutOutput2;

	// ────────────────────────────────
	// 🟩 SERIALIZED FIELDS (Grouped by Header)
	// - [Header] on its own line
	// - Inline all other attributes
	// - Lists before objects, objects before primitives
	// ────────────────────────────────

	[Header("Example Section A")]
	[SerializeField] [Tooltip("Tooltip for example value A")] private float exampleValueA;
	[SerializeField] [Tooltip("Tooltip for example value B")] private float exampleValueB;

	// Blank line between sections
	[Header("Example Section B")]
	[SerializeField] private List<GameObject> referencedObjects;
	[SerializeField] private List<int> exampleNumbers;
	[SerializeField] private Rigidbody exampleRigidbody;
	[SerializeField] private float additionalValueA;
	[SerializeField] private float additionalValueB;
	[SerializeField] private bool allowProcessing = true;

	// ────────────────────────────────
	// 🟩 NON-SERIALIZED FIELDS
	// - Grouped and sorted the same as serialized:
	//   Lists → Objects → Primitives
	// - Public before private
	// ────────────────────────────────
	public List<GameObject> publicListObjects;
	private List<GameObject> privateListObjects;

	public List<string> publicListPrimitives;
	private List<bool> privateListPrimitives;

	public GameObject anObject1;
	public bool aPrimitive1;

	private GameObject anObject2;
	private bool aPrimitive2;

	// ────────────────────────────────
	// 🟩 PROPERTIES
	// - Public auto-properties above methods
	// ────────────────────────────────
	public bool IsProcessing { get; private set; }

	// ────────────────────────────────
	// 🟩 UNITY EVENT METHODS
	// - Awake, Start, Update, etc.
	// - In Unity lifecycle order
	// ────────────────────────────────
	private void Awake()
	{
		if (exampleRigidbody == null)
			exampleRigidbody = GetComponent<Rigidbody>();
	}

	private void Start()
	{
		IsProcessing = false;
	}

	private void Update()
	{
		HandleExampleLogic();
		CheckExampleInput();
	}

	private void OnCollisionEnter(Collision collision)
	{
		if (collision.gameObject.CompareTag(ExampleSurfaceTag))
		{
			IsProcessing = false;
		}
	}

	// ────────────────────────────────
	// 🟩 STATIC METHODS
	// - Above instance methods
	// ────────────────────────────────
	public static string FormatDisplayName(string rawName)
	{
		return $"{internalIdPrefix}{rawName.ToUpper()}";
	}

	// ────────────────────────────────
	// 🟩 INSTANCE METHODS
	// - Public above private
	// ────────────────────────────────
	public void FirstPublicMethod()
	{
		// Some content
	}

	public void ResetExample(Vector3 position)
	{
		transform.position = position;
		exampleRigidbody.velocity = Vector3.zero;
		IsProcessing = false;
	}

	private IEnumerator ExampleRoutine()
	{
		yield return new WaitForSeconds(1f);
		anExampleBoolean = false;
	}

	private void HandleExampleLogic()
	{
		if (!allowProcessing) return;

		float inputX = Input.GetAxis("Horizontal");
		float inputZ = Input.GetAxis("Vertical");

		Vector3 direction = new Vector3(inputX, 0f, inputZ).normalized;
		Vector3 velocity = direction * processingSpeed;

		exampleRigidbody.velocity = new Vector3(velocity.x, exampleRigidbody.velocity.y, velocity.z);
	}

	private void CheckExampleInput()
	{
		if (Input.GetKeyDown(KeyCode.Space) && !IsProcessing)
		{
			exampleRigidbody.AddForce(Vector3.up * actionImpulse, ForceMode.Impulse);
			IsProcessing = true;
		}
	}
}
