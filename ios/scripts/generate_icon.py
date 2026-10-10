#!/usr/bin/env python3
"""Draw our four arithmetic glyphs as geometric shapes; Pillow is only needed to regenerate."""
from pathlib import Path
import json
from PIL import Image, ImageDraw
root=Path(__file__).resolve().parents[1]
scale=3
image=Image.new('RGB',(1024*scale,1024*scale),(19,47,41))
draw=ImageDraw.Draw(image)
def box(rect,fill): draw.rounded_rectangle(tuple(round(x*scale) for x in rect), radius=72*scale,fill=fill)
def line(points,fill,width=30):
    points=[tuple(round(c*scale) for c in p) for p in points]
    draw.line(points,fill=fill,width=width*scale)
    r=width*scale/2
    for x,y in points: draw.ellipse((x-r,y-r,x+r,y+r),fill=fill)
def dot(x,y,fill,r=20): draw.ellipse(((x-r)*scale,(y-r)*scale,(x+r)*scale,(y+r)*scale),fill=fill)
colors=[(212,240,218),(246,237,213),(232,164,116),(112,171,151)]
positions=[(112,112),(544,112),(112,544),(544,544)]
for (x,y),color in zip(positions,colors): box((x,y,x+368,y+368),color)
ink=(19,47,41)
line([(225,296),(367,296)],ink); line([(296,225),(296,367)],ink)
line([(657,296),(799,296)],ink)
line([(238,670),(354,786)],ink); line([(354,670),(238,786)],ink)
line([(657,728),(799,728)],ink); dot(728,661,ink); dot(728,795,ink)
image=image.resize((1024,1024),Image.Resampling.LANCZOS)
folder=root/'Arithmetics/Resources/Assets.xcassets/AppIcon.appiconset'
image.save(folder/'AppIcon.png',optimize=True)
(folder/'Contents.json').write_text(json.dumps({'images':[{'filename':'AppIcon.png','idiom':'universal','platform':'ios','size':'1024x1024'}],'info':{'author':'xcode','version':1}},indent=2)+'\n')
print('Created opaque RGB 1024x1024 icon.')
