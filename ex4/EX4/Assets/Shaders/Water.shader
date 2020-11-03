Shader "CG/Water"
{
    Properties
    {
        _CubeMap("Reflection Cube Map", Cube) = "" {}
        _NoiseScale("Texture Scale", Range(1, 100)) = 10 
        _TimeScale("Time Scale", Range(0.1, 5)) = 3 
        _BumpScale("Bump Scale", Range(0, 0.5)) = 0.05
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"
                #include "CGRandom.cginc"

                #define DELTA 0.01

                // Declare used properties
                uniform samplerCUBE _CubeMap;
                uniform float _NoiseScale;
                uniform float _TimeScale;
                uniform float _BumpScale;

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos      : SV_POSITION;
                    float2 uv       : TEXCOORD0;
                    float3 normal   : NORMAL;
                    float4 vertex   : TEXCOORD1;
                    float4 tangent  : TANGENT;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                   // return perlin2d(uv);
                    return perlin3d(float3(0.5 * uv.x, 0.5 * uv.y, 0.5 * t))
                        + 0.5 * perlin3d(float3(uv.x, uv.y, t)) + 0.2 * perlin3d(float3(2 * uv.x, 2 * uv.y, 3 * t));
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    float4 derive1 = (waterNoise(i.uv, t) - waterNoise(i.uv + float2(i.du, 0), t)) / i.du;
                    float u_derive = derive1.x;

                    float4 derive2 = (waterNoise(i.uv, t) - waterNoise(i.uv + float2(0, i.dv), t)) / i.dv;
                    float v_derive = derive2.y;


                    float3 nh = normalize(float3(-i.bumpScale * u_derive, -i.bumpScale * v_derive, 1));
                    float3 nh_worldSpace = mul(unity_ObjectToWorld, nh).xyz;
                    float3 n = normalize(i.normal);

                    float3 binormal = cross(n, i.tangent);
                    float3 n_world = i.tangent * nh.x + n * nh.z + binormal * nh.y;

                    return n_world;
                }


                v2f vert (appdata input)
                {
                    v2f output;
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.vertex = input.vertex;
                    output.tangent = input.tangent;
                    float displacement = perlin2d(input.uv * _NoiseScale) * _BumpScale;
                    output.pos = UnityObjectToClipPos(float3(input.vertex.x, input.vertex.y + displacement, input.vertex.z));  
                    return output;
                }

                fixed4 frag(v2f input) : SV_Target
                {
                    //return waterNoise(input.uv * _NoiseScale, 0) * 0.5 + 0.5;

                    float4 posWorld = mul(unity_ObjectToWorld, input.vertex);
                    float3 n = normalize(input.normal);
                    float3 v = normalize(float4(_WorldSpaceCameraPos, 0) - posWorld);
                    float3 r = 2 * dot(v, n) * n - v;
                    fixed4 reflectedColor = texCUBE(_CubeMap, r);
                    fixed4 color = (1 - max(0, dot(n, v)) + 0.2) * reflectedColor;
                    //return color;

                    bumpMapData i;
                    i.normal = n;
                    i.tangent = mul(unity_ObjectToWorld, input.tangent);
                    i.du = DELTA;
                    i.dv = DELTA;
                    i.uv = input.uv * _NoiseScale;
                    i.bumpScale = _BumpScale;
                   
                    float3 new_n = getWaterBumpMappedNormal(i, (_Time.y* _TimeScale));
                    r = 2 * dot(v, new_n) * new_n - v;
                    reflectedColor = texCUBE(_CubeMap, r);
                    color = (1 - max(0, dot(new_n, v)) + 0.2) * reflectedColor;

                    return color;
                }

            ENDCG
        }
    }
}
