#ifndef CG_UTILS_INCLUDED
#define CG_UTILS_INCLUDED

#define PI 3.141592653

// A struct containing all the data needed for bump-mapping
struct bumpMapData
{ 
    float3 normal;       // Mesh surface normal at the point
    float3 tangent;      // Mesh surface tangent at the point
    float2 uv;           // UV coordinates of the point
    sampler2D heightMap; // Heightmap texture to use for bump mapping
    float du;            // Increment size for u partial derivative approximation
    float dv;            // Increment size for v partial derivative approximation
    float bumpScale;     // Bump scaling factor
};


// Receives pos in 3D cartesian coordinates (x, y, z)
// Returns UV coordinates corresponding to pos using spherical texture mapping
float2 getSphericalUV(float3 pos)
{
    // Your implementation
    float r = pow(pow(pos.x, 2) + pow(pos.y, 2) + pow(pos.z, 2), 0.5);
    float theta = atan2(pos.z, pos.x);
    float phi = acos(pos.y / r);
    
    float u = (0.5 + theta) / (2 * PI);
    float v = 1 - (phi / PI);
 
    return float2(u, v);
}

// Implements an adjusted version of the Blinn-Phong lighting model
fixed3 blinnPhong(float3 n, float3 v, float3 l, float shininess, fixed4 albedo, fixed4 specularity, float ambientIntensity)
{
    // Your implementation
    fixed3 Ambient = ambientIntensity * albedo;
    fixed3 Diffuse = max(0.0, dot(n, l)) * albedo;
    float3 h = normalize((v + l) / 2);
    fixed3 Specular = pow(max(0.0, dot(n, h)), shininess) * specularity;
    
    
    return Ambient + Diffuse + Specular;
}

// Returns the world-space bump-mapped normal for the given bumpMapData
float3 getBumpMappedNormal(bumpMapData i)
{
    // Your implementation
    float4 derive1 = (tex2D(i.heightMap, i.uv) - tex2D(i.heightMap, i.uv + float2(i.du,0))) / i.du;
    float u_derive = derive1.x;

    float4 derive2 = (tex2D(i.heightMap, i.uv) - tex2D(i.heightMap, i.uv + float2(0,i.dv))) / i.dv;
    float v_derive = derive2.y;


    float3 nh = normalize(float3(-i.bumpScale*u_derive, -i.bumpScale * v_derive, 1));
    float3 nh_worldSpace = mul(unity_ObjectToWorld, nh).xyz;

  
    float3 binormal = cross(i.normal, i.tangent);
    float3 n_world = i.tangent * nh_worldSpace.x + i.normal * nh_worldSpace.z + binormal * nh_worldSpace.y;

    return n_world;
}


#endif // CG_UTILS_INCLUDED
