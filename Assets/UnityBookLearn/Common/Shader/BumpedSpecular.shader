Shader "Unity Shaders Book Learn/Common/Bumped Specular"
{
    Properties
    {
        _Color("Color Tint",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
        _BumpMap("Normal Map",2D)="bump"{}
        _Specular("Specular",Color) =(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "Queue"="Geometry"
        }
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex :POSITION;
                float3 normal:NORMAL;
                float4 tangent :TANGENT;
                float4 texcoord :TEXCOORD0;
            };

            struct v2f
            {
                float4 pos :SV_POSITION;
                float4 uv :TEXCOORD0;
                float4 TtoW0 :TEXCOORD1;
                float4 TtoW1 :TEXCOORD2;
                float4 TtoW2 :TEXCOORD3;
                SHADOW_COORDS(4)
            };


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump = normalize(half3(dot(i.TtoW0, bump), dot(i.TtoW1, bump), dot(i.TtoW2, bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * max(0, dot(bump, worldLightDir));

                fixed3 halfDir = normalize(worldViewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
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

            #pragma multi_compile_fwdadd
            //#pragma multi_compile_fwdadd_fullshadows
            
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex :POSITION;
                float3 normal:NORMAL;
                float4 tangent :TANGENT;
                float4 texcoord :TEXCOORD0;
            };

            struct v2f
            {
                float4 pos :SV_POSITION;
                float4 uv :TEXCOORD0;
                float4 TtoW0 :TEXCOORD1;
                float4 TtoW1 :TEXCOORD2;
                float4 TtoW2 :TEXCOORD3;
                SHADOW_COORDS(4)
            };


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump = normalize(half3(dot(i.TtoW0, bump), dot(i.TtoW1, bump), dot(i.TtoW2, bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * max(0, dot(bump, worldLightDir));

                fixed3 halfDir = normalize(worldViewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

                return fixed4(  (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}