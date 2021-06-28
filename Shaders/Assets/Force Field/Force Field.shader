Shader "Unlit/Force Field"
{
    Properties
    {
        _MainCol ("Main Color", Color) = (1,1,1,1)
        _FresnelCol ("Fresnel Color", Color) = (1,1,1,1)
        _Bias ("Bias", float) = 0
        _Scale ("Scale", float) = 1
        _Power ("Power", float) = 1

        _TestTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
        }

        ZWrite On

        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

        ENDHLSL

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct VertexInput
            {
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct FragmentInput
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;

                float3 vPosWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;

                float4 screenPos : TEXCOORD3;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _TestTex;
            float _Bias, _Scale, _Power;

            FragmentInput vert (VertexInput vi)
            {
                FragmentInput fi;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(vi.vertex);
                fi.vertex = positionInputs.positionCS;
                fi.vPosWS = positionInputs.positionWS;

                fi.uv = vi.uv;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(vi.normal);
                fi.normalWS = normalInputs.normalWS;

                
                fi.screenPos = ComputeScreenPos(positionInputs.positionCS);
                
                return fi;
            }

            float4 frag (FragmentInput fi, out float depth : SV_Depth) : SV_Target
            {
                depth = 1;

                float3 camToFrag = fi.vPosWS - _WorldSpaceCameraPos.xyz;
                float3 fresnel = _Bias + _Scale * pow(1 + dot(normalize(camToFrag), normalize(fi.normalWS)), _Power);

                float2 scrPos =  fi.screenPos.xy / fi.screenPos.w;
                //return float4(fresnel, 1);a
                return tex2D(_CameraDepthTexture, scrPos).x;
            }

            ENDHLSL
        }
    }

    Fallback "Diffuse"
}
