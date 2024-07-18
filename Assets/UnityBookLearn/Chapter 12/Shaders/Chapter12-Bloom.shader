Shader "Unity Shaders Book Learn/Chapter 12/Bloom"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Bloom("Bloom (RGB",2D)="black"{}
        _LuminanceThreshold("Luminance Threshold",Float) =0.5
        _BlurSize("Blur Size",Float)=1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _LuminanceThreshold;
        float _BlurSize;

        struct v2f
        {
            float4 pos :SV_POSITION;
            half2 uv: TEXCOORD0;
        };

        v2f vertExtractBright(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;

            return o;
        }

        fixed luminance(fixed4 color)
        {
            return dot(color, fixed3(0.2125, 0.7152, 0.0721));
        }

        fixed4 fragExtractBright(v2f i) : SV_Target
        {
            fixed4 c = tex2D(_MainTex, i.uv);
            fixed val = clamp(luminance(c) - _LuminanceThreshold, 0, 1.0);
            return c * val;
        }

        struct v2f_Bloom
        {
            float4 pos : SV_POSITION;
            half4 uv: TEXCOORD0;
        };

        v2f_Bloom vertBloom(appdata_img v)
        {
            v2f_Bloom o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            #ifdef UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0.0)
            {
                o.uv.w = 1 - o.uv.w;
            }
            #endif

            return o;
        }

        fixed4 fragBloom(v2f_Bloom i) : SV_Target
        {
            fixed4 texCol = tex2D(_MainTex, i.uv.xy);
            fixed4 bloomCol = tex2D(_Bloom, i.uv.zw);
            return texCol + bloomCol;
        }
        ENDCG



        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }

        UsePass "Unity Shaders Book Learn/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_VERTICAL"
        UsePass "Unity Shaders Book Learn/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_HORIZONTAL"
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            
            ENDCG
        }
    }
}