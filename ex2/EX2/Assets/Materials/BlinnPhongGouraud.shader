Shader "CG/BlinnPhongGouraud"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (0.14, 0.43, 0.84, 1)
        _SpecularColor ("Specular Color", Color) = (0.7, 0.7, 0.7, 1)
        _AmbientColor ("Ambient Color", Color) = (0.05, 0.13, 0.25, 1)
        _Shininess ("Shininess", Range(0.1, 50)) = 10
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

                // From UnityCG
                uniform fixed4 _LightColor0; 

                // Declare used properties
                uniform fixed4 _DiffuseColor;
                uniform fixed4 _SpecularColor;
                uniform fixed4 _AmbientColor;
                uniform float _Shininess;

                struct appdata
                { 
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    fixed4 color : COLOR0;
                };


                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    fixed3 n = normalize(mul(float4(input.normal, 0.0), unity_WorldToObject).xyz);
                    fixed4 l = normalize(_WorldSpaceLightPos0);
                    float4 posWorld = mul(unity_ObjectToWorld, input.vertex);
                    float3 v = normalize(_WorldSpaceCameraPos - posWorld.xyz);

                    // Diffuse component
                    fixed4 color_d = max(dot(l , n),0) * _DiffuseColor * _LightColor0;

                    //Ambient component
                    fixed4 color_a = _AmbientColor * _LightColor0;

                    //Specular component

                    fixed4 h =  normalize(fixed4((l.xyz + v) / 2, 0));
                    fixed4 color_s = pow(max(dot(n , h), 0), _Shininess) * _SpecularColor * _LightColor0;

                    output.color = color_d + color_a + color_s;

                    
                    return output;
                }


                fixed4 frag (v2f input) : SV_Target
                {
                   return input.color;
                }

            ENDCG
        }
    }
}
