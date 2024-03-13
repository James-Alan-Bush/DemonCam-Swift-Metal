//
//  HighlightsAndShadows.metal
//  DemonCam-Swift-Metal
//
//  Created by Xcode Developer on 3/13/24.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

[[ stitchable ]] half4 highlightsShadows(float2 position, half4 color,
                                         float highlights, float shadows,
                                         float red, float green, float blue)
{
    half3 luminanceWeighting = half3(red, green, blue);
    half luminance = dot(color.rgb, luminanceWeighting);
    half shadow = clamp((pow(luminance, 1.0h/(half(shadows)+1.0h)) + (-0.76)*pow(luminance, 2.0h/(half(shadows)+1.0h))) - luminance, 0.0, 1.0);
     half highlight = clamp((1.0 - (pow(1.0-luminance, 1.0/(2.0-half(highlights))) + (-0.8)*pow(1.0-luminance, 2.0/(2.0-half(highlights))))) - luminance, -1.0, 0.0);
     half3 result = half3(0.0, 0.0, 0.0) + ((luminance + shadow + highlight) - 0.0) * ((color.rgb - half3(0.0, 0.0, 0.0))/(luminance - 0.0));
     
     return half4(result.rgb, color.a);
 }
