Shader "Unity Shaders Book Learn/Chapter 11/Billboard"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color("Color Tint",Color) =(1,1,1,1)
        _VerticalBillboarding("Vertical Restrains",Range(0,1))=1
    }
    SubShader
    {
        //Need to disable batching because of the vertex animation
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _VerticalBillboarding;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                //Suppose the center in object space is fiexd
                float3 center=float3 (0,0,0);
                float3 viewDir=mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
                
                float3 normal=viewDir-center;
                //If _VerticalBillboarding equals 1, we use the desired view dir as the normal dir
                //Which means the normal dir is fixed
                //Or if _VerticalBillboarding equals 0 , the y of normal is 0
                //Which means the up dir is fixed
                normal.y*= _VerticalBillboarding;
                normal=normalize(normal);

                //Get the approximate up dir
                //If normal dir is already towards up, then the up dir is towards front
                fixed3 upDir= abs(normal.y)>0.999?float3(0,0,1):float3(0,1,0);
                fixed3 rightDir=normalize(cross(upDir,normal));
                upDir=normalize(cross(normal,rightDir));

                float3 posOffset=v.vertex.xyz-center;
                float3 localPos=center+posOffset.x*rightDir+posOffset.z*normal+posOffset.y*upDir;


                
                o.pos = UnityObjectToClipPos(localPos);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                return col;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}