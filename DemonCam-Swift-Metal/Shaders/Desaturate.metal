//
//  Desaturate.metal
//  DemonCam-Swift-Metal
//
//  Created by Xcode Developer on 3/6/24.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

[[ stitchable ]] half4 desaturate(float2 position, half4 color,
                                  float red, float green, float blue, float alpha)
{
    half4 desaturated = dot(half4(red, green, blue, alpha), half4(color.rgb, 1.0 - alpha));
    
    return desaturated;
}
