Shader "Unity Shaders Book Learn/Chapter 12/Edge Detection"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _EdgeOnly("Edge Only",Float)=1
        _EdgeColor("Edge Color",Color)=(0,0,0,1)
        _BackgroundColor("Background Color",Color)=(1,1,1,1)

    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;


            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 uv[9] : TEXCOORD0;
            };

            v2f vert(appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                half2 uv = v.texcoord;

                o.uv[0] = uv + _MainTex_TexelSize * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize * half2(1, 1);


                return o;
            }

            half luminance(fixed3 color)
            {
                return dot(color, half3(0.2125, 0.7152, 0.0721));
            }

            half Sobel(v2f i)
            {
                const half Gx[9] = {
                    -1, 0, 1,
                    -2, 0, 2,
                    -1, 0, 1
                };
                const half Gy[9] = {
                    -1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                };

                half edgeX = 0;
                half edgeY = 0;

                for (int index = 0; index < 9; index++)
                {
                    half edgeLuminance = luminance(tex2D(_MainTex, i.uv[index]));
                    edgeX += Gx[index] * edgeLuminance;
                    edgeY += Gy[index] * edgeLuminance;
                }
                return 1 - abs(edgeX) - abs(edgeY);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half edgeSobel = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edgeSobel);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edgeSobel);

                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }
            ENDCG
        }
    }
    Fallback Off
}