Shader "Unlit/Test"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,0)
        _Gloss ("Gloss", Float) = 1
    }
    SubShader
    {
        Tags 
        { 
            "RenderPipeline" = "UniversalPipeline" 
            "RenderType" = "Opaque"
        }

        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

        ENDHLSL

        Pass
        {
            Tags 
            { 
                "LightMode"="UniversalForward" 
            }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            

            struct VertexInput
            {
                float3 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct FragmentInput
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                
                float3 worldPos : TEXCOORD0;
            };

            float4 _Color;
            float _Gloss;

            FragmentInput vert (VertexInput input)
            {
                FragmentInput f;
                
                f.normal = input.normal;

                VertexPositionInputs vi = GetVertexPositionInputs(input.vertex);
                f.worldPos = vi.positionWS;

                f.vertex = vi.positionCS;

                return f;
            }

            float Posterize(float steps, float value)
            {
                return floor(value * steps) / steps;
            }

            float4 frag (FragmentInput f) : SV_Target
            {
                // Lighting
                float3 lightDir = _MainLightPosition.xyz;
                float3 ligthColor = _MainLightColor.rgb;
                float3 normal = normalize(f.normal);
                float lightVal = Posterize(4, saturate(dot(lightDir, normal)));

                // Ambient light
                float3 ambientLight = float3(0.1,0.1,0.1);

                // Diffuse light
                float3 diffuseLight = (ligthColor * lightVal) + ambientLight;

                

                // Direct specular light
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - f.worldPos.xyz;
                float3 viewDir = normalize(fragToCam);

                float3 viewReflect = reflect(-viewDir, normal);

                float specularVal = saturate(dot(viewReflect, lightDir));
                float modifiedSpec = Posterize(3, pow(specularVal, _Gloss));

                // Fresnel
                //float fresnelIntensity = 1 / dot(viewDir, normal);  // If dot(viewDir, normal) gets close to 0, we are on the object edge
                //float3 fresnel = float3(fresnelIntensity, fresnelIntensity, fresnelIntensity);

                // Composite
                float3 finalColor = diffuseLight * _Color.rgb + modifiedSpec;

                return float4(finalColor, 0);
            }

            ENDHLSL
        }
    }

    Fallback "Diffuse"
}
