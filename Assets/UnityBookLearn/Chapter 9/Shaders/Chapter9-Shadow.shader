Shader "Unity Shaders Book Learn/Chapter 9/Shadow"
{
    Properties
    {
        _Diffuse("Diffuse",Color) =(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma multi_compile_fwdbase
            
            #pragma vertex vert
            #pragma fragment frag
   

            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal :TEXCOORD0;
                float3 worldPos :TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                //Pass shadow coordinates to pixel shader
                TRANSFER_SHADOW(o);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                fixed atten = 1.0;

                //Use shadow coordinates to sample shadow map
                fixed shadow = SHADOW_ATTENUATION(i);
                return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardAdd"
            }

            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"


            #pragma multi_compile_fwdadd
            
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal :TEXCOORD0;
                float3 worldPos :TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir= normalize( _WorldSpaceLightPos0.xyz- i.worldPos);
                #endif


                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                #ifdef USING_DIRECTIONAL_LIGHT
                fixed atten = 1.0;
                #else
                #if defined(POINT)
                        float3 lightCoord=mul(unity_WorldToLight,float4(worldLightDir,1));
                        fixed atten=tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr) .UNITY_ATTEN_CHANNEL;
                #elif defined(SPOT)
                        float4 lightCoord=mul(unity_WorldToLight,float4(worldLightDir,1));
                        fixed atten =(lightCoord.z>0) * tex2D(_LightTextureB0,lightCoord.xy/lightCoord.w +0.5).w * tex2D( _LightTextureB0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #else
                        fixed atten = 1.0;
                #endif
                #endif


                return fixed4((diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}