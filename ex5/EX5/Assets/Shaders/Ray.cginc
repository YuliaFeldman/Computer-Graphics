// ========== Material ==========

struct Material
{
    float3 albedo; // Diffuse coefficient k_d
    float3 specular; // Specular coefficient k_s
    float refractiveIndex; // Index of refraction, -1 if the material is not refractive
};

Material CreateMaterial(float3 albedo, float3 specular)
{
    Material material;
    material.albedo = albedo;
    material.specular = specular;
    material.refractiveIndex = -1;
    return material;
}

Material CreateRefractiveMaterial(float refractiveIndex)
{
    Material material = CreateMaterial(0, 0);
    material.refractiveIndex = refractiveIndex;
    return material;
}

// ========== Ray ==========

struct Ray
{
    float3 origin; // Origin point of the ray
    float3 direction; // Direction vector of the ray
    float3 energy; // Energy of the ray, 3 channel RGB
};

Ray CreateRay(float3 origin, float3 direction, float3 energy)
{
    Ray ray;
    ray.origin = origin;
    ray.direction = direction;
    ray.energy = energy;
    return ray;
}

Ray CreateViewRay(float2 uv)
{
    // Transform the camera origin to world space
    float3 origin = mul(_CamToWorld, float4(0.0f, 0.0f, 0.0f, 1.0f)).xyz;
    
    // Invert the perspective projection of the view-space position
    float3 direction = mul(_CamInverseProjection, float4(uv, 0.0f, 1.0f)).xyz;

    // Transform the direction from camera to world space and normalize
    direction = mul(_CamToWorld, float4(direction, 0.0f)).xyz;
    direction = normalize(direction);
    return CreateRay(origin, direction, 1);
}


// ========== RayHit ==========

struct RayHit
{
    float3 position; // Spatial position of the hit point
    float distance; // Distance t from the ray origin
    float3 normal; // Normal of the intersected surface at the hit point
    Material material; // Material of the intersected surface
};

RayHit CreateRayHit()
{
    RayHit hit;
    hit.position = float3(0,0,0);
    hit.distance = 1.#INF; // Infinity
    hit.normal = 0;
    hit.material = CreateMaterial(0, 0);
    return hit;
}