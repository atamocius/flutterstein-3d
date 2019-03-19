import'dart:async';
import'dart:convert';
import'dart:math';
import'dart:ui';
import'dart:typed_data';
import'package:flutter/services.dart';
import'package:vector_math/vector_math.dart';

var w=window,
    rb=rootBundle,
    vz=Vector2.zero(),
    c0=0xff000000,
    cf=0xFFFFFFFF,
    jdc=jsonDecode,
    oz=Offset.zero;
typedef bool P(int btn);
k(v)=>v.floor();
fr(v)=>v-k(v);
iA(v)=>(1/v).abs();
sq(v)=>v*v;
co(b,s,p)=>(k(b*s)&0xff)<<p;
gs(s,[b=255])=>(c0|co(b,s,16)|co(b,s,8)|co(b,s,0))&cf;
it(d)=>d.cast<int>();
dt(d)=>d.cast<double>();
f3(v)=>Float32List(v);

li(k)async{
  var c=Completer<Image>();
  decodeImageFromList(Uint8List.view((await rb.load(k)).buffer),(i)=>c.complete(i));
  return c.future;
}

ll(k)async{
  var d=jdc(await rb.loadString(k));
  return L(it(d['m']),d['s'],await li(d['i']),d['t'],v(dt(d['p'])),v(dt(d['d'])),it(d['c']),it(d['f']));
}

lb(k,r,s,b,i)async{
  var d=jdc(await rb.loadString(k));
  return B(
      r,
     (d['t']as List)
          .map((t)=>RSTransform.fromComponents(rotation:t[0],scale:s,anchorX:0,anchorY:0,translateX:t[1]*b.width+t[3]*s,translateY:t[2]*b.height+t[4]*s,))
          .toList(),
      rt(d['u']),
      rt(d['d']),
      it(d['m']),
     (d['a']as List)
          .map((a)=>RRect.fromRectAndRadius(Rect.fromCircle(center:Offset(a[0],a[1])*s+Offset(a[3]*b.width,a[4]*b.height),radius:a[2]*s),Radius.circular(a[2]*s)))
          .toList(),
      i);
}

rt(List l)=>l.map((r)=>Rect.fromLTWH(r[0],r[1],r[2],r[3])).toList();

v(v)=>Vector2(v[0],v[1]);

class L{
  Image i;
  int s,a;
  Vector2 p,d;
  List<int> m,c,f;

  L(this.m,this.s,this.i,this.a,this.p,this.d,this.c,this.f);

  g(x,y)=>m[(s-k(y)-1)*s+k(x)];
}

class B{
  num r;
  List<RSTransform> t;
  List<Rect> u,d,e;
  List<int> m;
  var o=List.filled(6,Color(cf));
  List<RRect> a;
  Image i;
  Paint p;
  int s;

  B(this.r,this.t,this.u,this.d,this.m,this.a,this.i):s=0,e=List<Rect>.from(u),p=Paint();

  rd(Canvas c){c.drawAtlas(i,t,e,o,BlendMode.dstIn,null,p);}

  bool b(b)=>s&m[b]>0;

  ud(List<PointerData>p){
    s=0;
    for(var d in p)
      if(d.change==PointerChange.up)s=0;else{
        for(int i=0;i<a.length;i++)
          if(a[i].contains(Offset(d.physicalX/r,d.physicalY/r)))
            s|=1<<i;
      }

    for(int i=0;i<e.length;i++)e[i]=s&m[i]>0?d[i]:u[i];
  }
}

class R{
  L l;
  Size z;
  Vector2 p,d,pn;
  Image m;
  int s;
  Float32List t,g;
  Int32List cs;
  Rect br;
  Paint bp;
  var tW=32,
      hw=.85,
      _d=vz.clone(),
      dd=vz.clone(),
      rd=vz.clone(),
      sp=Paint(),
      se=4;

  R(this.z,this.l)
     :p=l.p.clone(),
        d=l.d.clone(),
        m=l.i,
        s=l.a,
        br=Rect.fromLTRB(0,-20,z.width,z.height+20),
        bp=Paint()
          ..shader=Gradient.linear(
            oz,
            Offset(0,z.height),
            [l.c[0],l.c[1],c0,c0,l.f[1],l.f[0]]
                .map((c)=>Color(c))
                .toList(),
            [0,.35,.45,.55,.65,1],
          ){
    pn=Vector2(d.y,-d.x)
      ..normalize()
      ..scale(hw);

    var w=z.width~/1,s=se;
    t=f3(w*s);
    g=f3(w*s);
    cs=Int32List(w);
  }

  r(Canvas c){
    for(int x=0;x<z.width;x++)_r(x);
    c.drawRect(br,bp);
    c.drawRawAtlas(m,t,g,cs,BlendMode.modulate,null,sp);
  }

  _r(x){
    var w=z.width,h=z.height,cX=2*x/w-1;

    rd
      ..setZero()
      ..addScaled(pn,cX)
      ..add(d);

    int mX=k(p.x),mY=k(p.y),sX=0,sY=0,ht=0,sd;

    dd.x=iA(rd.x);
    dd.y=iA(rd.y);

    if(rd.x<0){
      sX=-1;
      _d.x=(p.x-mX)*dd.x;
    }else{
      sX=1;
      _d.x=(mX+1.0-p.x)*dd.x;
    }
    if(rd.y<0){
      sY=-1;
      _d.y=(p.y-mY)*dd.y;
    }else{
      sY=1;
      _d.y=(mY+1.0-p.y)*dd.y;
    }

    while(ht==0){
      if(_d.x<_d.y){
        _d.x+=dd.x;
        mX+=sX;
        sd=0;
      }else{
        _d.y+=dd.y;
        mY+=sY;
        sd=1;
      }

      if(l.g(mX,mY)>0)ht=1;
    }

    var dx=mX-p.x,
        dy=mY-p.y,
        pwd=sd==0?(dx+(1-sX)/2)/rd.x:(dy+(1-sY)/2)/rd.y,
        lh=h/pwd,
        wX=sd==0?p.y+pwd*rd.y:p.x+pwd*rd.x;
    wX=fr(wX);

    int tX=k(wX*tW);
    if(sd==0&&rd.x>0)tX=tW-tX-1;
    if(sd==1&&rd.y<0)tX=tW-tX-1;

    var tn=l.g(mX,mY)-1,
        oX=tn % s*tW/1,
        oY=tn~/s*tW/1,
        i=x*se,
        sc=lh/tW,
        ds=-lh/2+h/2;

    t
      ..[i]=sc
      ..[i+1]=0
      ..[i+2]=x/1
      ..[i+3]=ds;
    g
      ..[i]=oX+tX
      ..[i+1]=oY
      ..[i+2]=oX+tX+1/sc
      ..[i+3]=oY+tW;

    var q=sq(dx)+sq(dy),att=1-min(sq(q/100),1);
    cs[x]=gs(att,sd==1?255:200);
  }
}

class G{
  R _r;
  L _l;
  var _rm=Matrix2.identity(),_mv=vz.clone(),_s=3.0,_rs=1.7,_w=.2;

  num _bt=.0,_bf=10,_ba=2;

  G(Size s,this._l):_r=R(s,_l);

  u(t,b){
    var fw=b(0),
        bw=b(2),
        sL=b(1),
        sR=b(3),
        rL=b(4),
        rR=b(5),
        m=_s*t,
        r=_rs*t,
        d=_r.d,
        p=_r.p,
        pn=_r.pn;

    if(fw||bw){
      _mv.x=d.x*m*(fw?1:-1);
      _mv.y=d.y*m*(fw?1:-1);
    }

    if(sL||sR){
      _mv.x=d.y*m*(sL?1:-1);
      _mv.y=-d.x*m*(sL?1:-1);
    }

    if(fw||bw||sL||sR){
      _bt+=t*_bf;
      _tl(_l,p,_mv,_w);
    }

    if(rL||rR){
      _rm
        ..setRotation(r*(rL?1:-1))
        ..transform(d)
        ..transform(pn);
    }
  }

  r(Canvas c){
    c
      ..save()
      ..translate(0,sin((pi/2)*_bt)*_ba);
    _r.r(c);
    c.restore();
  }

  _tl(l,p,d,w){
    if(l.g(p.x+d.x,p.y)==0)p.x+=d.x;
    if(l.g(p.x,p.y+d.y)==0)p.y+=d.y;

    var fX=fr(p.x),fY=fr(p.y);

    if(d.x<0){
      if(l.g(p.x-1,p.y)>0&&fX<w)p.x+=w-fX;
    }else{
      if(l.g(p.x+1,p.y)>0&&fX>1-w)p.x-=fX-(1-w);
    }
    if(d.y<0){
      if(l.g(p.x,p.y-1)>0&&fY<w)p.y+=w-fY;
    }else{
      if(l.g(p.x,p.y+1)>0&&fY>1-w)p.y-=fY-(1-w);
    }
  }
}

main()async{
  await SystemChrome.setEnabledSystemUIOverlays([]);

  var vs=Size(640,360),
      b=oz & vs,
      dt=Float64List(16),
      ba=await li('i/b.png');

  Offset o;
  B bs;

  var h=()async{
    var sz=w.physicalSize,r=sz.shortestSide/vs.shortestSide;

    dt
      ..[0]=r
      ..[5]=r
      ..[10]=1
      ..[15]=1;

    o=(sz/r-vs as Offset)*.5;

    bs=await lb('d/b.json',r,1/r*w.devicePixelRatio,oz & sz/r,ba);
  };

  h();
  w.onMetricsChanged=h;

  var l=await ll('d/l.json'),g=G(vs,l),z=Duration.zero,pv=z;

  w.onBeginFrame=(n){
    var r=PictureRecorder(),
        c=Canvas(r,b),
        d=pv==z?z:n-pv,
        t=d.inMicroseconds/1000000;
    pv=n;

    c
      ..save()
      ..translate(o.dx,o.dy)
      ..clipRect(b);
    g
      ..u(t,bs.b)
      ..r(c);
    c.restore();

    bs.rd(c);

    var p=r.endRecording(),
        br=SceneBuilder()
          ..pushTransform(dt)
          ..addPicture(oz,p)
          ..pop();

    w
      ..render(br.build())
      ..scheduleFrame();
  };

  w
    ..scheduleFrame()
    ..onPointerDataPacket=(p)=>bs.ud(p.data);
}
