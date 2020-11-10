// Implements an adjusted version of the Blinn-Phong lighting model
float3 blinnPhong(float3 n, float3 v, float3 l, float shininess, float3 albedo)
{
    float3 h = normalize((v + l) / 2);
    float3 diffuse = max(0, dot(n, l)) * albedo;
    float3 specular = pow(max(0, dot(n, h)), shininess) * 0.4;
    return diffuse + specular;
}

// Reflects the given ray from the given hit point
void reflectRay(inout Ray ray, RayHit hit)
{
    float3 n = hit.normal;
    float3 v = -ray.direction;
    float3 r = 2 * dot(v, n) * n - v;
    ray.direction = r;
    ray.origin = hit.position + EPS * n;
    ray.energy *= hit.material.specular;
}

// Refracts the given ray from the given hit point
void refractRay(inout Ray ray, RayHit hit)
{

        
      float3 n = normalize(hit.normal);
      float3 i = normalize(ray.direction);
      float refraction1 = 1;
      float refraction2 = hit.material.refractiveIndex;
      float direction = dot(n, i);
      if (direction > 0)
      {
          n = -n;
          refraction1 = refraction2;
          refraction2 = 1;
      }
  
      float refractionIdx = refraction1 / refraction2;
      float c1 = abs(dot(n, i));
      float c2 = pow(1 - (pow(refractionIdx, 2) * (1 - pow(c1, 2))),0.5);
      float3 t = refractionIdx * i + ((refractionIdx * c1) - c2) * n;
      ray.direction = t;
      ray.origin = hit.position - (n * EPS);
    
}

// Samples the _SkyboxTexture at a given direction vector
float3 sampleSkybox(float3 direction)
{
    float theta = acos(direction.y) / -PI;
    float phi = atan2(direction.x, -direction.z) / -PI * 0.5f;
    return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
}