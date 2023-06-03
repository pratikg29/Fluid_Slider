//
//  ContentView.swift
//  SliderFluidAnimation
//
//  Created by Pratik Gadhesariya on 27/05/23.
//

import SwiftUI

struct ContentView: View {
    private let color: Color = Color("blue")
    @State private var offset: CGFloat = 0
    var rectSize = CGSize(width: 300, height: 50)
    var rectSize2 = CGSize(width: 300, height: 25)
    var circleSize: CGFloat = 50
    @GestureState var isDragging: Bool = false
    @State var previousOffset: CGFloat = 0
    @State private var isBeating: Bool = false
    
    var body: some View {
        GeometryReader { bounds in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    upShiftingSlider
                    slider
                }
            }
        }
    }
    
    
    private var upShiftingSlider: some View {
        ZStack {
            Canvas { context, size in
                context.addFilter(.alphaThreshold(min: 0.5, max: 1, color: color))
                context.addFilter(.blur(radius: 7))
                
                context.drawLayer { ctx in
                    if let rectangle = ctx.resolveSymbol(id: "Rectangle") {
                        ctx.draw(rectangle, at: CGPoint(x: size.width/2, y: size.height/2))
                    }
                    if let circle = ctx.resolveSymbol(id: "Circle") {
                        ctx.draw(circle, at: CGPoint(x: size.width/2 - rectSize.width/2 + circleSize/2, y: size.height/2))
                    }
                }
            } symbols: {
                Capsule()
                    .fill(Color.blue)
                    .frame(width: rectSize.width, height: rectSize.height, alignment: .center)
                    .tag("Rectangle")
                
                Circle()
                    .fill(Color.pink)
                    .frame(width: circleSize, height: circleSize, alignment: .center)
                    .offset(x: offset, y: isDragging ? -rectSize.height - 6 : 0)
                    .animation(animation, value: isDragging)
                    .tag("Circle")
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging, body: { _, state, _ in
                        state = true
                    })
                    .onChanged({ value in
                        self.offset = min(max(self.previousOffset + value.translation.width, 0), rectSize.width - circleSize)
                    })
                    .onEnded({ value in
                        self.previousOffset = self.offset
                    })
            )
            
            Circle()
                .fill(Color.black)
                .frame(width: circleSize - 10, height: circleSize - 10, alignment: .center)
                .overlay {
                    Text("\(percentage)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .offset(x: (-rectSize.width/2) + (circleSize/2))
                .offset(x: offset, y: isDragging ? -rectSize.height - 7 : 0)
                .animation(animation, value: isDragging)
                .allowsHitTesting(false)
        }
        .frame(height: 200)
    }
    
    private var slider: some View {
        ZStack {
            Canvas { context, size in
                context.addFilter(.alphaThreshold(min: 0.5, max: 1, color: color))
                context.addFilter(.blur(radius: 10))
                
                context.drawLayer { ctx in
                    if let rectangle = ctx.resolveSymbol(id: "Rectangle") {
                        ctx.draw(rectangle, at: CGPoint(x: size.width/2, y: size.height/2))
                    }
                    if let circle = ctx.resolveSymbol(id: "Circle") {
                        ctx.draw(circle, at: CGPoint(x: size.width/2 - rectSize2.width/2 + circleSize/2, y: size.height/2))
                    }
                }
            } symbols: {
                Rectangle()
                    .frame(width: rectSize2.width, height: rectSize2.height, alignment: .center)
                    .tag("Rectangle")
                
                Circle()
                    .frame(width: circleSize, height: circleSize, alignment: .center)
                    .offset(x: offset)
                    .animation(.spring(), value: isDragging)
                    .tag("Circle")
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging, body: { _, state, _ in
                        state = true
                    })
                    .onChanged({ value in
                        self.offset = min(max(self.previousOffset + value.translation.width, 0), rectSize2.width - circleSize)
                    })
                    .onEnded({ value in
                        self.previousOffset = self.offset
                    })
            )
            .background {
                Color.black
            }
            
            Circle()
                .fill(Color.black)
                .frame(width: circleSize - 14)
                .overlay {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                        .scaleEffect(isDragging ? 1 : 0.6)
                        .scaleEffect(isBeating ? 0.8 : 1)
                        
                }
                .offset(x: (-rectSize2.width/2) + (circleSize/2))
                .offset(x: offset)
                .animation(.spring(), value: isDragging)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                        isBeating.toggle()
                    }
                }
        }
        .frame(height: 200)
    }
    
    
    private var animation: Animation {
        .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5)
    }
    
    private var percentage: Int {
        Int((offset) / (rectSize.width - circleSize) * 100)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
