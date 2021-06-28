Shader "Unlit/Shore"
{
    Properties
    {
        _MainTex ("Shoreline", 2D) = "black" {}
        _Color ("ShoreColor", Color) = (1,1,1,1)
        _SeaColor ("SeaColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags 
        { 
            "RenderPipeline" = "UniversalPipeline" 
            "RenderType"="Opaque" 
        }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct FragmentInput
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _Color;
            float4 _SeaColor;

             float Posterize(float steps, float value)
            {
                return floor(value * steps) / steps;
            }

            FragmentInput vert (VertexInput vi)
            {
                FragmentInput fi;

                fi.vertex = TransformObjectToHClip(vi.vertex);
                fi.uv = vi.uv;

                return fi;
            }

            float4 frag (FragmentInput fi) : SV_Target
            {
                float shore = tex2D(_MainTex, fi.uv).x;
                
                float waveSize = 0.02;
                float waveSpeedMultiplier = 3;

                float shape = shore;//fi.uv.y;

                float waveVal = (sin(shape / waveSize + _Time.y * waveSpeedMultiplier) + 1) * shore;
                return lerp(_SeaColor, _Color, waveVal);
            }

            ENDHLSL
        }
    }
}
