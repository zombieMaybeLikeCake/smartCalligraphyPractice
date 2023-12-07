from typing import Any
import torch
import torchvision.transforms as transforms
from torchvision.utils import save_image, make_grid
from model.model import chk_mkdir
from torch.utils.data import DataLoader, TensorDataset
from data import DatasetFromObj
from model import Zi2ZiModel
import os
import argparse
import random
import time
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import cgi
from os import listdir
import os.path as osp
import base64,io
import time
import io
import json
from io import BytesIO
IP='192.168.0.103'
PATH=r"C:\Users\robert\Desktop\zi2zi-pytorch-master\testsample"
path=r"C:\Users\robert\Desktop\project\標楷體labelme\標楷體"
savepath=r"C:\Users\robert\Desktop\zi2zi-pytorch-master\testsample"
outpath=r"C:\Users\robert\Desktop\zi2zi-pytorch-master\testsample"
result=r"C:\Users\robert\Desktop\zi2zi-pytorch-master\lab6\infer\finaloutput.png"
experiment_dir="lab6"
IsFirst=True
nownum=0
num=1
checkpoint_dir = os.path.join(experiment_dir, "checkpoint")
infer_dir = os.path.join(experiment_dir, "infer")
canvas_size=256
label=0
offest=0
ratio=0.0
substyle=0
isblendered=False
# isblender=False
strokered=0
strokegreen=0
strokeblue=0
strokealph=255
outputimg=Image.new("L",(768 ,1024),(255))
src_font="BiauKai.ttf"
char_size=256
model = Zi2ZiModel(
        input_nc=1,
        embedding_num=40,
        embedding_dim=128,
        Lconst_penalty=15,
        Lcategory_penalty=1.0,
        save_dir=checkpoint_dir,
        gpu_ids=["cuda:0"],
        is_training=False
    )
model.setup()
model.load_networks(3000)
def image_to_base64(image):
    output_buffer = BytesIO()
    image.save(output_buffer, format='PNG')
    byte_data = output_buffer.getvalue()
    base64_str = base64.b64encode(byte_data)
    return base64_str
def fitbest(image):
    image=image.convert('L')
    npimage = np.asarray(image).copy()
    max_x=0
    min_x=10000
    max_y=0
    min_y=10000
    (imgwidth,imgheight)=image.size
    for i in range(0,imgheight):
        for j in range(0,imgwidth):
            if(npimage[i][j]<100):
                max_x=max(i,max_x)
                min_x=min(i,min_x)
                max_y=max(j,max_y)
                min_y=min(j,min_y)
    image=image.crop((min_y-1,min_x-1,max_y+1,max_x+1))
    width=max_y-min_y+2
    height=max_x-min_x+2
    # print(width,height)
    canvas_size=max(width,height)
    example_img = Image.new("L", (canvas_size , canvas_size), (255))
    if width>height:
        example_img.paste(image,(0,int((canvas_size-height)/2)))
    else:
        example_img.paste(image,(int((canvas_size-width)/2),0))
    # example_img.show()
    return [example_img,canvas_size,min_x,min_y,width,height,imgwidth,imgheight]
def reduction(image,canvas_size,minx,miny,width,height,oringalimgheight,oringalimgwidth):
    # print("argurment:")
    # print(width,height)
    image=image.convert('L')
    image.resize((canvas_size,canvas_size))
    npimage = np.asarray(image).copy()
    max_x=0
    min_x=10000
    max_y=0
    min_y=10000
    (imgwidth,imgheight)=image.size
    for i in range(0,imgheight):
        for j in range(0,imgwidth):
            if(npimage[i][j]<100):
                max_x=max(i,max_x)
                min_x=min(i,min_x)
                max_y=max(j,max_y)
                min_y=min(j,min_y)
    image=image.crop((min_y-1,min_x-1,max_y+1,max_x+1))
    image=image.resize((width-2,height-2))
    oringalimg = Image.new("L",(oringalimgheight,oringalimgwidth),(255))
    oringalimg.paste(image,(miny,minx))
    return oringalimg
def singalereduction(image,canvas_size,minx,miny,width,height,oringalimgheight,oringalimgwidth,goalcolor):
    # image=image.convert('L')
    image = image.convert('RGBA')
    # print("imagesize:")
    # print(image.size)
    # image.resize((canvas_size,canvas_size))
    # print(image.size)
    # npimage = np.asarray(image).copy()
    max_x=0
    min_x=10000
    max_y=0
    min_y=10000
    (imgwidth,imgheight)=image.size
    for i in range(imgwidth):
        for j in range(imgheight):
            color = image.getpixel((i, j))
            if (color[0]*30 + color[1]*59 + color[2]*11 + 50)/100>240:
                color = color[:-1] + (0,)
                image.putpixel((i, j), color)
            elif(color[0]*30 + color[1]*59 + color[2]*11 + 50)/100<200:
                color = color[:-1] + (255,)
                max_x=max(i,max_x)
                min_x=min(i,min_x)
                max_y=max(j,max_y)
                min_y=min(j,min_y)
                image.putpixel((i, j), goalcolor)
            # else:
            #     color = color[:-1] + (int(255*(color[0]+color[1]+color[2])/3/240), )
            #     image.putpixel((i, j),color)
    # for i in range(0,imgheight):
    #     for j in range(0,imgwidth):
    #         if(npimage[i][j]<100):
                # max_x=max(i,max_x)
                # min_x=min(i,min_x)
                # max_y=max(j,max_y)
                # min_y=min(j,min_y)
    # image=image.crop((min_y-1,min_x-1,max_y+1,max_x+1))
    # image=image.resize((width-2,height-2))
    # image=image.resize((canvas_size-2,canvas_size-2))
    # image.show()
    # print("width:")
    # print(width)
    # print("height")
    # print(height)
    stroke={
        # "xPosition":(max_y-min_y)/2,
        # "yPosition":(max_x-min_x)/2,
        "xPosition":miny+(width)/2,
        "yPosition":minx+(height)/2,
        "width":max(width,height),
        "height":max(width,height),
        "image":str(image_to_base64(image),encoding='utf-8')
    }
    # print(stroke)
    stroke_json = json.dumps(stroke,indent = 4) 
    # print(stroke_json)
    return stroke_json
def overlay(img1,img2):
   (imgwidth,imgheight)=img1.size
   img1=img1.convert('L')
   img2=img2.convert('L')
#    print(img1.size)
   npimg1 = np.asarray(img1).copy()
   npimg2 = np.asarray(img2).copy()
   for i in range(0,imgheight):
      for j in range(0,imgwidth):
        if((npimg1[i][j]>=128)and(npimg2[i][j]<=128)):
            npimg1[i][j]=npimg2[i][j]
   img1=Image.fromarray(npimg1)
   return img1
def draw_single_char(ch, font, canvas_size):
    img = Image.new("RGB", (canvas_size, canvas_size), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    draw.text((0, 0), ch, (0, 0, 0), font=font)
    img = img.convert('L')
    return img
def image2byte(image):
    '''
    图片转byte
    image: 必须是PIL格式
    image_bytes: 二进制
    '''
    # 创建一个字节流管道
    img_bytes = io.BytesIO()
    #把PNG格式转换成的四通道转成RGB的三通道，然后再保存成jpg格式
    image = image.convert("RGB")
    # 将图片数据存入字节流管道， format可以按照具体文件的格式填写
    image.save(img_bytes, format="JPEG")
    # 从字节流管道中获取二进制
    image_bytes = img_bytes.getvalue()
    return image_bytes

class   PostHandler(BaseHTTPRequestHandler):
    def do_GET(self):

        
        global label,isblendered,offest,ratio,substyle,strokered,strokegreen,strokeblue,strokealph
        # 解析请求路径和查询参数
        parsed_url = urlparse(self.path)
        query_params = parse_qs(parsed_url.query)
        # 获取文件名参数
        # if 'next' in query_params:
        #     global wordindex
        #     wordindex+=1
        #     path=str(wordindex)
        #     self.send_header('Content-type', 'text/html')
        #     self.end_headers()
        #     self.wfile.write(bytes(path, 'utf8'))
        #     print(wordindex)
        if "red" in query_params:
            strokered=int(query_params['red'][0])
        if "green" in query_params:
            strokegreen=int(query_params['green'][0])
        if "blue" in query_params:
            strokeblue=int(query_params['blue'][0])
        if "alph" in query_params:
            strokealph=int(query_params['alph'][0])
        if "stytle" in query_params:
            stytleindex = str(query_params['stytle'][0])
            print("style:")
            print(stytleindex)
            stytleindex=int(stytleindex)
            label=stytleindex
        if 'goalword' in query_params:
            goalword = query_params['goalword'][0]
            try:
                # model.load_networks(15000)
                model.load_networks(6000)
                # 打开请求的图像文件
                # with open(path+"\\"+filename,'rb') as file:
                #     image_data = file.read()
                # 设置响应状态码和响应头，指定图像的Content-Type
                print(goalword)
                print(label)
                font = ImageFont.truetype(src_font, size=char_size)
                img_list = [transforms.Normalize(0.5, 0.5)(
                    transforms.ToTensor()(
                        draw_single_char(ch, font, canvas_size)
                     )
                ).unsqueeze(dim=0) for ch in goalword]    
                label_list = [label for _ in goalword]
                img_list = torch.cat(img_list, dim=0)
                label_list = torch.tensor(label_list)
                dataset = TensorDataset(label_list, img_list, img_list)
                dataloader = DataLoader(dataset, batch_size=32, shuffle=False)
                for batch in dataloader:
                    if isblendered:
                        print("BLENDER MODE")
                        print("mainstyle:"+str(label))
                        print("substyle:"+str(label-offest))
                        output=model.blender(batch,infer_dir,offest,ratio)
                    else:
                        print("NO BLENDER MODE")
                        output=model.sample(batch,infer_dir)
                jsondata = json.dumps(output)
                # print(jsondata)
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(jsondata.encode('utf-8'))
                # 发送图像数据作为响应内容
                # self.wfile.write(image_data)
            except FileNotFoundError:
                # 如果文件未找到，返回404 Not Found
                self.send_response(404)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(b'File Not Found')
            model.load_networks(3000)
        if "blender" in query_params:
            isblendered=True
            print(query_params['blender'][0])
            if len(query_params['blender'][0])==3 or len(query_params['blender'][0])==2:
                checkstr=str(query_params['blender'][0])
                substytle=int(checkstr[0])
                if substytle==0:
                    isblendered=False
                else:
                    # print("substyle"+str(substyle))
                    offest=label-substytle+1
                ratio=int(checkstr[1:])/100
            else:
                checkstr=str(query_params['blender'][0])
                substytle=int(checkstr[0]+checkstr[1])
                offest=label-substytle+1
                ratio=int(checkstr[2:])/100
        elif not 'goalword' in query_params: 
            isblendered=False
    def do_POST(self):
        global num,IsFirst,outputimg,strokered,strokegreen,strokeblue,strokealph
        srcimgs=[]
        form = cgi.FieldStorage(
            fp=self.rfile,
            headers=self.headers,
            environ={'REQUEST_METHOD':'POST',
                     'CONTENT_TYPE':self.headers['Content-Type']
                     }
        )
        # self.wfile.write('Form data:'.encode("utf-8"))
        field_item = form.value
        b64=field_item[6:]
        imgdata = base64.b64decode(b64)
        imgdata = Image.open(io.BytesIO(imgdata))
        imgfinfo=fitbest(imgdata)
        img=imgfinfo[0]
        img=img.resize((canvas_size,canvas_size))
        srcimgs.append(img)
        src = srcimgs
        img_list = [transforms.Normalize(0.5, 0.5)(
                            transforms.ToTensor()(
                                ch
                            )
                ).unsqueeze(dim=0) for ch in src]
        label_list = [label for _ in src]
        img_list = torch.cat(img_list, dim=0)
        label_list = torch.tensor(label_list)
        dataset = TensorDataset(label_list, img_list, img_list)
        dataloader = DataLoader(dataset,batch_size=32,shuffle=False)
        for batch in dataloader:
            if IsFirst:
                dict=model.singalsample(batch,infer_dir)
                outputimg=dict["0.png"]
                # outputimg=reduction(outputimg,imgfinfo[1],imgfinfo[2],imgfinfo[3],imgfinfo[4],imgfinfo[5],imgfinfo[6],imgfinfo[7])
                outputjson=singalereduction(outputimg,imgfinfo[1],imgfinfo[2],imgfinfo[3],imgfinfo[4],imgfinfo[5],imgfinfo[6],imgfinfo[7],(strokered,strokegreen,strokeblue,strokealph))
                # outputimg.save(osp.join(infer_dir,"finaloutput.png"))
                IsFirst=False
            else:
                dict=model.singalsample(batch,infer_dir)
                img=dict["0.png"]
                # img=reduction(img,imgfinfo[1],imgfinfo[2],imgfinfo[3],imgfinfo[4],imgfinfo[5],imgfinfo[6],imgfinfo[7])
                # outputimg = overlay(outputimg,img)
                outputjson=singalereduction(img,imgfinfo[1],imgfinfo[2],imgfinfo[3],imgfinfo[4],imgfinfo[5],imgfinfo[6],imgfinfo[7],(strokered,strokegreen,strokeblue,strokealph))
                # outputimg.save(osp.join(infer_dir,"finaloutput.png"))
        # filename = str(num)+".png" # I assume you have a way of picking unique filenames
        # with open(osp.join(savepath,filename), "wb") as f: 
        #     f.write(imgdata)
        # with open(osp.join(outpath,filename),'rb') as file:
        #     image_data = file.read()

        # outputfile = io.BytesIO()
        # outputimg.save(outputfile, format="PNG")
        # outputfile = outputfile.getvalue()
        self.send_response(200)
        self.end_headers()
        # with open(osp.join(outpath,filename),'rb') as f:
        # # with open(osp.join(result), "rb") as f: 
        #     image_data = f.read()
        # self.wfile.write(outputfile)
        self.wfile.write(bytes(outputjson , encoding = "utf8"))
        num+=1
        return
if __name__ == '__main__':
    sever = HTTPServer((IP,8080),PostHandler)
    print( 'Listening : ip = %s' % str(IP))
    print('Listening : port = %d' % 8080) 
    print( 'HttpServer Starting , use <Ctrl-C> to stop')
    sever.serve_forever()
    # with torch.no_grad():
    #     main()
