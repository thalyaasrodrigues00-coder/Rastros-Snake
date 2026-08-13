using UnityEngine;

/// <summary>
/// Applies position and scale changes via Vector3 while preserving
/// parent-child hierarchy and local matrix consistency.
/// </summary>
public static class TransformVectorApplier
{
    public struct TransformVectors
    {
        public Vector3 Position;
        public Vector3 Scale;
        public bool ApplyPosition;
        public bool ApplyScale;

        public static TransformVectors Local(Vector3 position, Vector3 scale)
        {
            return new TransformVectors
            {
                Position = position,
                Scale = scale,
                ApplyPosition = true,
                ApplyScale = true,
            };
        }

        public static TransformVectors LocalPosition(Vector3 position)
        {
            return new TransformVectors
            {
                Position = position,
                ApplyPosition = true,
                ApplyScale = false,
            };
        }

        public static TransformVectors LocalScale(Vector3 scale)
        {
            return new TransformVectors
            {
                Scale = scale,
                ApplyPosition = false,
                ApplyScale = true,
            };
        }
    }

    /// <summary>
    /// Applies local position and/or scale directly in the object's local space.
    /// Children keep their own local transforms; hierarchy stays aligned.
    /// </summary>
    public static void ApplyLocal(Transform target, TransformVectors vectors)
    {
        if (target == null)
        {
            Debug.LogWarning("TransformVectorApplier: target is null.");
            return;
        }

        if (vectors.ApplyPosition)
        {
            target.localPosition = vectors.Position;
        }

        if (vectors.ApplyScale)
        {
            target.localScale = vectors.Scale;
        }
    }

    /// <summary>
    /// Applies world position and/or scale, converting to local values
    /// so the parent-child hierarchy and local matrix remain consistent.
    /// </summary>
    public static void ApplyWorldPreservingHierarchy(Transform target, TransformVectors vectors)
    {
        if (target == null)
        {
            Debug.LogWarning("TransformVectorApplier: target is null.");
            return;
        }

        if (vectors.ApplyPosition)
        {
            SetWorldPosition(target, vectors.Position);
        }

        if (vectors.ApplyScale)
        {
            SetWorldScale(target, vectors.Scale);
        }
    }

    /// <summary>
    /// Sets world position by updating localPosition relative to the parent.
    /// </summary>
    public static void SetWorldPosition(Transform target, Vector3 worldPosition)
    {
        if (target.parent == null)
        {
            target.position = worldPosition;
            return;
        }

        target.localPosition = target.parent.InverseTransformPoint(worldPosition);
    }

    /// <summary>
    /// Sets world scale by updating localScale relative to the parent's lossy scale.
    /// </summary>
    public static void SetWorldScale(Transform target, Vector3 worldScale)
    {
        if (target.parent == null)
        {
            target.localScale = worldScale;
            return;
        }

        Vector3 parentLossyScale = target.parent.lossyScale;
        target.localScale = new Vector3(
            SafeDivide(worldScale.x, parentLossyScale.x),
            SafeDivide(worldScale.y, parentLossyScale.y),
            SafeDivide(worldScale.z, parentLossyScale.z)
        );
    }

    /// <summary>
    /// Reads current local TRS as vectors without touching rotation.
    /// Useful to inspect state before applying changes.
    /// </summary>
    public static TransformVectors GetLocalVectors(Transform target)
    {
        return new TransformVectors
        {
            Position = target.localPosition,
            Scale = target.localScale,
            ApplyPosition = true,
            ApplyScale = true,
        };
    }

    /// <summary>
    /// Offsets local position and multiplies local scale by the given vectors.
    /// Hierarchy and child local matrices remain intact.
    /// </summary>
    public static void OffsetLocal(Transform target, Vector3 positionDelta, Vector3 scaleMultiplier)
    {
        if (target == null)
        {
            return;
        }

        target.localPosition += positionDelta;
        target.localScale = Vector3.Scale(target.localScale, scaleMultiplier);
    }

    private static float SafeDivide(float value, float divisor)
    {
        return Mathf.Approximately(divisor, 0f) ? value : value / divisor;
    }
}

/// <summary>
/// MonoBehaviour wrapper. Attach to any GameObject and call Apply from code
/// or invoke via UnityEvent / Inspector buttons in Play Mode.
/// </summary>
[DisallowMultipleComponent]
public class TransformVectorController : MonoBehaviour
{
    public enum SpaceMode
    {
        Local,
        WorldPreservingHierarchy,
    }

    [Header("Target (defaults to this GameObject)")]
    [SerializeField] private Transform target;

    [Header("Space")]
    [SerializeField] private SpaceMode spaceMode = SpaceMode.Local;

    [Header("Position (X, Y, Z)")]
    [SerializeField] private Vector3 position = Vector3.zero;
    [SerializeField] private bool applyPosition = true;

    [Header("Scale (X, Y, Z)")]
    [SerializeField] private Vector3 scale = Vector3.one;
    [SerializeField] private bool applyScale = true;

    private void Reset()
    {
        target = transform;
        scale = Vector3.one;
    }

    private void Awake()
    {
        if (target == null)
        {
            target = transform;
        }
    }

    /// <summary>
    /// Applies configured position and scale vectors to the target.
    /// </summary>
    public void ApplyConfiguredVectors()
    {
        ApplyToTarget(target, BuildVectors());
    }

    /// <summary>
    /// Applies position and scale vectors to any Transform at runtime.
    /// </summary>
    public void ApplyToTarget(Transform object3D, Vector3 newPosition, Vector3 newScale)
    {
        ApplyToTarget(object3D, new TransformVectorApplier.TransformVectors
        {
            Position = newPosition,
            Scale = newScale,
            ApplyPosition = true,
            ApplyScale = true,
        });
    }

    /// <summary>
    /// Applies vectors using the selected space mode.
    /// </summary>
    public void ApplyToTarget(Transform object3D, TransformVectorApplier.TransformVectors vectors)
    {
        if (object3D == null)
        {
            Debug.LogWarning($"{nameof(TransformVectorController)}: object3D is null.");
            return;
        }

        switch (spaceMode)
        {
            case SpaceMode.Local:
                TransformVectorApplier.ApplyLocal(object3D, vectors);
                break;

            case SpaceMode.WorldPreservingHierarchy:
                TransformVectorApplier.ApplyWorldPreservingHierarchy(object3D, vectors);
                break;
        }
    }

    private TransformVectorApplier.TransformVectors BuildVectors()
    {
        return new TransformVectorApplier.TransformVectors
        {
            Position = position,
            Scale = scale,
            ApplyPosition = applyPosition,
            ApplyScale = applyScale,
        };
    }

#if UNITY_EDITOR
    [ContextMenu("Apply Configured Vectors")]
    private void EditorApplyConfiguredVectors()
    {
        if (target == null)
        {
            target = transform;
        }

        ApplyConfiguredVectors();
    }
#endif
}
