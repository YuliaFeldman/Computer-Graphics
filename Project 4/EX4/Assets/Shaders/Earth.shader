Shader "CG/Earth"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(1, 100)) = 30
        [NoScaleOffset] _CloudMap ("Cloud Map", 2D) = "black" {}
        _AtmosphereColor ("Atmosphere Color", Color) = (0.8, 0.85, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
                uniform float _BumpScale;
                uniform sampler2D _CloudMap;
                uniform fixed4 _AtmosphereColor;

                struct appdata
                { 
                    float4 vertex : POSITION;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float4 vertex: TEXCOORD1;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.vertex = input.vertex;
                    return output;
                }

                fixed4 frag(v2f input) : SV_Target
                {
                    float4 posWorld = mul(unity_ObjectToWorld, input.vertex);
                    float2 uv = getSphericalUV(posWorld);
                    fixed4 Albedo_color = tex2D(_AlbedoMap, uv);
                    fixed4 specularity = tex2D(_SpecularMap, uv);

                    float3 n = normalize(posWorld.xyz);
                    float3 l = normalize(_WorldSpaceLightPos0);
                    float3 v = normalize(float4(_WorldSpaceCameraPos, 0) - posWorld);

                    bumpMapData i;
                    i.normal = n;
                    i.tangent = mul(unity_ObjectToWorld, cross(n, float3(0, 1, 0)));
                    i.du = _HeightMap_TexelSize.x;
                    i.dv = _HeightMap_TexelSize.y;
                    i.uv = uv;
                    i.heightMap = _HeightMap;
                    i.bumpScale = _BumpScale / 10000;
                    float3 new_n = getBumpMappedNormal(i);

                    float Lambert = max(0, dot(n, l));
                    float4 Atmosphere = (1 - max(0, dot(n, v))) * pow(Lambert, 0.5) * _AtmosphereColor;
                    fixed4 Clouds = tex2D(_CloudMap, uv) * (pow(Lambert, 0.5) + _Ambient);

                    fixed3 color = blinnPhong(new_n, v, l, _Shininess, Albedo_color, specularity, _Ambient) +
                        Atmosphere + Clouds;
                    return fixed4(color, 1);
                }

            ENDCG
        }
    }
}
