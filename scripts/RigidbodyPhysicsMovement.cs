using UnityEngine;

/// <summary>
/// Physics-based movement using Rigidbody.MovePosition or Rigidbody.AddForce.
/// All physics calls run inside FixedUpdate() for stable simulation.
/// </summary>
[RequireComponent(typeof(Rigidbody))]
[DisallowMultipleComponent]
public class RigidbodyPhysicsMovement : MonoBehaviour
{
    public enum MovementMode
    {
        MovePosition,
        AddForce,
    }

    public enum ForceModeType
    {
        Force,
        Acceleration,
        Impulse,
        VelocityChange,
    }

    [Header("References")]
    [SerializeField] private Rigidbody targetRigidbody;

    [Header("Movement")]
    [SerializeField] private MovementMode movementMode = MovementMode.MovePosition;
    [SerializeField] private ForceModeType forceMode = ForceModeType.Force;
    [SerializeField] private float moveSpeed = 5f;
    [SerializeField] private float forceStrength = 10f;

    [Header("Input (optional)")]
    [SerializeField] private bool useAxisInput = true;
    [SerializeField] private string horizontalAxis = "Horizontal";
    [SerializeField] private string verticalAxis = "Vertical";

    private Vector3 _moveDirection = Vector3.zero;
    private bool _hasMoveRequest;

    private void Reset()
    {
        targetRigidbody = GetComponent<Rigidbody>();
    }

    private void Awake()
    {
        if (targetRigidbody == null)
        {
            targetRigidbody = GetComponent<Rigidbody>();
        }
    }

    private void Update()
    {
        if (!useAxisInput)
        {
            return;
        }

        float horizontal = Input.GetAxisRaw(horizontalAxis);
        float vertical = Input.GetAxisRaw(verticalAxis);

        Vector3 direction = new Vector3(horizontal, 0f, vertical);
        if (direction.sqrMagnitude > 1f)
        {
            direction.Normalize();
        }

        SetMoveDirection(direction);
    }

    /// <summary>
    /// Physics simulation must run here, not in Update().
    /// </summary>
    private void FixedUpdate()
    {
        if (targetRigidbody == null || !_hasMoveRequest)
        {
            return;
        }

        ApplyPhysicsMovement(targetRigidbody, _moveDirection, movementMode, moveSpeed, forceStrength, forceMode);
        _hasMoveRequest = false;
    }

    /// <summary>
    /// Sets the movement direction to be applied on the next FixedUpdate().
    /// </summary>
    public void SetMoveDirection(Vector3 direction)
    {
        _moveDirection = direction;
        _hasMoveRequest = direction.sqrMagnitude > 0.0001f;
    }

    /// <summary>
    /// Moves the Rigidbody immediately inside FixedUpdate context.
    /// Call this only from FixedUpdate() or from this component flow.
    /// </summary>
    public void MoveByDirection(Vector3 direction)
    {
        if (targetRigidbody == null)
        {
            return;
        }

        ApplyPhysicsMovement(targetRigidbody, direction, movementMode, moveSpeed, forceStrength, forceMode);
    }

    /// <summary>
    /// Core physics movement function.
    /// Uses MovePosition for direct displacement or AddForce for force-based motion.
    /// </summary>
    public static void ApplyPhysicsMovement(
        Rigidbody rb,
        Vector3 direction,
        MovementMode mode,
        float moveSpeed,
        float forceStrength,
        ForceModeType forceModeType = ForceModeType.Force)
    {
        if (rb == null || direction.sqrMagnitude <= 0.0001f)
        {
            return;
        }

        Vector3 normalizedDirection = direction.normalized;

        switch (mode)
        {
            case MovementMode.MovePosition:
                ApplyMovePosition(rb, normalizedDirection, moveSpeed);
                break;

            case MovementMode.AddForce:
                ApplyAddForce(rb, normalizedDirection, forceStrength, forceModeType);
                break;
        }
    }

    /// <summary>
    /// Moves the Rigidbody to a new world position using physics timestep.
    /// Best for kinematic-like control with collision response.
    /// </summary>
    public static void ApplyMovePosition(Rigidbody rb, Vector3 direction, float speed)
    {
        Vector3 delta = direction * speed * Time.fixedDeltaTime;
        Vector3 targetPosition = rb.position + delta;
        rb.MovePosition(targetPosition);
    }

    /// <summary>
    /// Applies force to the Rigidbody for acceleration-based movement.
    /// Best for realistic physics and inertia.
    /// </summary>
    public static void ApplyAddForce(
        Rigidbody rb,
        Vector3 direction,
        float strength,
        ForceModeType forceModeType = ForceModeType.Force)
    {
        ForceMode unityForceMode = ConvertForceMode(forceModeType);
        rb.AddForce(direction * strength, unityForceMode);
    }

    /// <summary>
    /// Moves toward a specific world point using MovePosition.
    /// </summary>
    public static void MoveTowardsPoint(Rigidbody rb, Vector3 worldTarget, float speed)
    {
        if (rb == null)
        {
            return;
        }

        Vector3 nextPosition = Vector3.MoveTowards(
            rb.position,
            worldTarget,
            speed * Time.fixedDeltaTime
        );

        rb.MovePosition(nextPosition);
    }

    /// <summary>
    /// Stops horizontal velocity while preserving vertical velocity (useful for jumps).
    /// Call inside FixedUpdate().
    /// </summary>
    public static void StopHorizontalVelocity(Rigidbody rb)
    {
        if (rb == null)
        {
            return;
        }

        Vector3 velocity = rb.velocity;
        velocity.x = 0f;
        velocity.z = 0f;
        rb.velocity = velocity;
    }

    private static ForceMode ConvertForceMode(ForceModeType forceModeType)
    {
        return forceModeType switch
        {
            ForceModeType.Force => ForceMode.Force,
            ForceModeType.Acceleration => ForceMode.Acceleration,
            ForceModeType.Impulse => ForceMode.Impulse,
            ForceModeType.VelocityChange => ForceMode.VelocityChange,
            _ => ForceMode.Force,
        };
    }
}

/// <summary>
/// Example consumer that keeps all Rigidbody calls inside FixedUpdate().
/// </summary>
[RequireComponent(typeof(Rigidbody))]
public class PhysicsMovementDriver : MonoBehaviour
{
    [SerializeField] private Rigidbody rb;
    [SerializeField] private float speed = 6f;
    [SerializeField] private RigidbodyPhysicsMovement.MovementMode mode =
        RigidbodyPhysicsMovement.MovementMode.MovePosition;

    private Vector3 _inputDirection;

    private void Awake()
    {
        rb ??= GetComponent<Rigidbody>();
    }

    private void Update()
    {
        // Input is read in Update(), physics is applied in FixedUpdate().
        _inputDirection = new Vector3(
            Input.GetAxisRaw("Horizontal"),
            0f,
            Input.GetAxisRaw("Vertical")
        );
    }

    private void FixedUpdate()
    {
        RigidbodyPhysicsMovement.ApplyPhysicsMovement(
            rb,
            _inputDirection,
            mode,
            speed,
            forceStrength: speed * 2f
        );
    }
}
