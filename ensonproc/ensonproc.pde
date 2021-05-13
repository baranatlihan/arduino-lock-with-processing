//controlp5 ve sound library indirildi
import controlP5.*;                    //grafik arayüz oluşturmak için kullanılan "controlP5" kütüphanesi import edildi.
import processing.serial.*;            //Processing ve Arduino arasındaki haberleşme için "serial"  kütüphanesi import edildi.
import processing.sound.*;             //Ses eklemek için "sound" kütüphanesi import edildi.
//Serial port;                         //Arduino haberleşmesi için port tanımlandı.
MatrixEffect a1 = new MatrixEffect();  //Her bir matrix Objesine kendi rasgele sütununda, rasgele karakterler yazan bir obje olarak bakabiliriz
MatrixEffect a2 = new MatrixEffect();  //Her bir Matrix Effect Objesi İnitialize ediliyor
MatrixEffect a3 = new MatrixEffect();  //Her bir sütun kendi başlangıç değerlerini alıyor...
MatrixEffect a4 = new MatrixEffect();
MatrixEffect a5 = new MatrixEffect();
MatrixEffect a6 = new MatrixEffect();
MatrixEffect a7 = new MatrixEffect();

int gelen;                              //processing ve arduino iletşimi için gerekli gelen değişkeni
PImage led_resim;                       //Led fotoğrafı tanımlandı.
PFont font, font2;                      //Arayüzdeki yazılar için font lar tanımlandı.
String klavye_giris,str="";             //Arayüzdeki yazılar ve import string'i tanımlandı.
String password = "4231";               //Doğru şifre olarak tanımlandı.
int control=3,controlcolors=2;          //yeşil ışık yakmak için //controlcolors:Matrix Effect objesinin kontrol renkleri (yesil:2(default),mavi:1(doğru olan),kırmızı:0(Yanlış))
int m = millis();                       //5saniye yeşil led yakmak için
ControlP5 cp5;                          //kontrol objesi yaratıldı
ControlEvent theEvent;                  //Mause haraketlerini inceleyen ControlEvent 
SoundFile acilma,hata;                  //Ses çalmak için eklenecek dosyaların adları

Textarea output,output2;                //output1 hatalı ya da dogru giriş uyarısı, output2 mause ile basılan tuş outputu

void setup() {
  background(0);
  size (600, 400);                              //arayüz penceresi boyutu
  led_resim = loadImage("led.png");             //fotoğraf eklendi
  font = createFont("Arial Black", 24);         //font tanımları
  font2 = createFont("Arial Black", 16);  
  acilma = new SoundFile(this, "acilma.aiff");  //ses dosyalarının yaratılması
  hata = new SoundFile(this,"hata.aiff");
  
  printArray(Serial.list()); // bütün avaible serial portları yazdırır
  //port = new Serial(this,"COM4", 9600); //windows arduino to com4 
  
  cp5 = new ControlP5(this);  //Grafik Arayüz için ControlP5 nesnesi
  
  //klavye & mause girisi için 
  cp5.addTextfield("4 HANELI SIFREYI GIRINIZ").setPosition(20, 270).setFocus(false)           //Klavyeden input almak için oluşturulmuş textfield tanımı
  .setAutoClear(false).setSize(100, 40).setFont(font2);     
  
  output = cp5.addTextarea("output").setPosition(260, 270)
  .setSize(300, 240).setFont(font2)
  .setColor(color(255)); //hatalı ya da dogru giriş uyarısı veren textarea

  cp5.addButton("ONAYLA").setPosition(140, 270).setSize(80, 40);  //inputları almak için basılan onaylanma butonu
 
  output2 = cp5.addTextarea("mauseoutput")
  .setPosition(250, 100).setSize(300, 240) //mause ile basılan tuş arayüzde göstermek için oluşturulmuş textarea
  .setFont(font).setColor(color(255));
  
  cp5.addButton("reset").setPosition(550, 0).setSize(50, 50); //Programı tekrar başlatmak (resetlemek) için oluşturulmuş reset butonu
  

  //1 2 3 4 giris butonlar
  cp5.addButton("1").setPosition(50, 150).setSize(50, 50);
  cp5.addButton("2").setPosition(110, 150).setSize(50, 50);
  cp5.addButton("3").setPosition(170, 150).setSize(50, 50);
  cp5.addButton("4").setPosition(230, 150).setSize(50, 50);
  
}

void draw() {
  a1.display(); //Her bir Matrix Effect objesinin(Görsel Sütunun) display() fonksiyonunu çalıştırıyoruz
  a3.display(); //display() fonksiyonu görsel olarak yukarıdan aşağıya rasgele harflerin görüntülendiği fonksiyon
  a2.display();     
  a4.display(); 
  a5.display(); 
  a6.display(); 
  a7.display(); 
  a1.check(controlcolors);  // Her bir objenin, kapının açılıp açılmama durumunu kontrol ettiği bölüm.
  a2.check(controlcolors);  // Kapının açılıp açılmama durumunun değişmesiyle beraber her bir objenin renginin değişmesini amaçlıyoruz.
  a3.check(controlcolors);  // Daha önce de belirttiğim gibi (controlcolors:(yeşil:default),(kırmızı:yanlış),(açık mavi:doğru))
  a4.check(controlcolors); // control colors iki şekilde değişebilir 1- Processing üzerinden giriş, 2-Arduino üzerinden (Kart veya dokunmatik tuş takımı)   
  a5.check(controlcolors); // control colors, genel durumun kontrol edildiği "control" değişkenine bağlı.
  a6.check(controlcolors);
  a7.check(controlcolors);
    
   noStroke(); //şekillerdeki çerçeveyi kaldırır 
   image(led_resim, 400, 100, width/6, height/4); //(x kord,y kord,,);
  
   //yazı
   fill(255);
   textFont(font);    //yazının fontu
   text("Fare ile Giriş:", 50, 130); //yazının konumu ve içeriği

   // Giriş Bilgileri ışığında görsel olarak değişimlerin yaşandığı kısım. Şifrenin eşleştiği senaryo:(control=1), Şifrenin eşleşmediği senaryo:(control=0), Bekleme:(control=3) 
   if(control==0){ //Yanlış girilmiş ise
     controlcolors=0; //Matrix Effect'in bütün objeleri bir sonraki draw dönüşünde "check()" fonksiyonuna 0 göndererek her bir efektin kırmızı renkte olmasını
      fill(255,0,0); //sağlayacaktır. Tabi ki temel amaç yaklaşık olarak 5 saniye gibi bir süre bu değişimin gözlemlenmesi ve arayüzümüzün eski haline dönmesidir.
      ellipse(450,140,32,32); 
      m++;
      if(m > 299){
        m=0;// =~ yaklaşık 5 sn
       control=3; //control değişkeninin sonraki giriş bilgisini alana kadar ne doğru senaryo; ne de yanlış senaryo bölümüne girmemesi için 3 atıyoruz.
       controlcolors=2;//5 saniyelik beklemeden sonra Matrix Effect objelerinin bekleme rengine(yeşil) dönmeleri için controlcolors değişkenine 2' atıyoruz.
     }
   }
 
   if(control == 1 || control == 2){ //Giriş Başarılıysa
     controlcolors=1; // Doğru giriş için her bir Matrix Effect objesinin bir sonraki çizimde açık mavi olmasını sağlıyoruz. 
       if(control==2){
         output2.setText("****"); //giriş işlemi sırasında şifrenin görünmemesi için output değişikliği
       }
     fill(0,255,0);
     ellipse(450,140,32,32);
     m++;
   
     if(m > 299){
       m=0;// =~ yaklaşık 5 sn
       control=3;     // //control değişkeninin sonraki giriş bilgisini alana kadar ne doğru senaryo; ne de yanlış senaryo bölümüne girmemesi için 3 atıyoruz.
       controlcolors=2;  //5 saniyelik beklemeden sonra Matrix Effect objelerinin bekleme rengine(yeşil) dönmeleri için controlcolors değişkenine 2' atıyoruz.
     }
   }  
  }



  void ONAYLA() { 
  
     m=0; //her giriş işleminde dogru olursa baştan süreyi sıfırlamak için
     if(klavye_giris != "1" || klavye_giris != "2" || klavye_giris != "3" || klavye_giris != "4"){   //girilen değerler 1-2-3-4 numaralar olmak şartıyla
     klavye_giris = cp5.get(Textfield.class,"4 HANELI SIFREYI GIRINIZ").getText(); 
   
     }
        //port.write(0);  GERÇEK DEVREDE DE AÇILIŞ
     if(klavye_giris.equalsIgnoreCase(password)) {    //girilen değerler tanımlanan şifreyle uyuşuyorsa
       output.setText("ŞİFRE EŞLEŞTİ! \nKİLİT AÇILDI.."); // arayüze şifrenin eşleştiğini ve kilidin açıldığını yazdırır
       acilma.play();    //Açılma durumunda çalınacak sesin play() ile oynatılması
       control=1;      //Problemde istenilen 5saniye süreli yanacak yeşil ışık için kontrol değişkeni
       //port.write('1'); //Arduino'ya girişin başarılı olduğunu belirtiyoruz.(Klavye ile başarılı giriş sağlandı.)

      }
   else if (str.equalsIgnoreCase(password)) {  //controlEvent fonksiyonunda kontrol edilen mause ile butonlara basılarak oluşturulan inputun kontrolü
     output.setText("ŞİFRE EŞLEŞTİ! \nKİLİT AÇILDI.."); // arayüze şifrenin eşleştiğini ve kilidin açıldığını yazdırır
     acilma.play();         //Açılma durumunda çalınacak sesin play() ile oynatılması
     control=2;          //Problemde istenilen 5saniye süreli yanacak yeşil ışık için kontrol değişkeni
     //port.write('1'); //Arduino'ya girişin başarılı olduğunu belirtiyoruz.(Mouse ile başarılı giriş sağlandı.) 

   }
   
    else {
      output.setText("HATALI GİRİŞ!\nLÜTFEN 4 HANELİ \nDOĞRU ŞİFREYİ GİRİNİZ..."); //if durumları doğru değilse hatalı giriş olduğunu arayüze yazdırma
      hata.play();
      //port.write('2'); //Arduino'ya girişin Hatalı Olduğunu Belirtiyoruz.
      control=0;
      }
      
}

//ONAYLA ve RESET butonu ve controlEvent fonksiyonu
void controlEvent(ControlEvent theEvent) {
  str+=(theEvent.getController().getName());    //butonlara basılınca butonların string olarak içine alınması     
     if(!str.contains("ONAYLA") && !str.contains("reset") ){  //eğer butonlar "ONAYLA" ve "reset" butonları değilse 
  output2.setText(str);            //girilen değerleri arayüze yazdırma
  }
  else if(str.contains("reset"))  //eğer basılan buton "reset" butonu ise 
    reset();        //tanımlanan reset fonksiyonu çağırısı
}


void reset(){
  output.setText("");  //arayüzdeki Stringleri sıfırlamak için 
  output2.setText("");  //arayüzdeki Stringleri sıfırlamak için 
  draw();    //tekrar draw yaparak diğer elemanların resetlenmesi için
  str="";    //girdi olan string i sıfırlamak için
}



class MatrixEffect //Bütün Matrix Effect objelerinin üyesi olduğu sınıf
{
private float range; //Her bir objenin, rasgele belirlenmiş, yukarıdan aşağıya yazılacak olan rasgele karakterinin gidebileceği maksimum mesafe.
private float ypos;  // Yazılan karakterin x-y koordinat düzlemindeki değişken 'y' pozisyonu
private float xpos;  //Her bir mesafe tamamlamada rasgele belirlenen, yazılan karakterin x eksenini belirten değişken  
private float speed=10; // Temsili hız olarak tanımlanan bu değişken aslında bir sonraki rasgele karakterin bir öncekinden ne kadar uzakta olacağını gösterir.(y ekseninde)
private char character; // draw() fonksiyonunun her bir dönüşünde, her bir Matrix Effect objesinin ekrana yansıtacağı rasgele karakter
private int count; //İlerde kullanılan "ERODE" efektini kontrol etmemize yarayan değişken. Burada temel amaç ekranı sürekli olarak değil kesikli olarak ERODE yapmak için.
private color colorr; // Her bir objenin karakter rengi

  MatrixEffect(){ //Her bir efektin yapıcı fonksiyonu
    range=random(0,height); // Yukarıdan (y=0) aşağıya(y=height) rasgele mesafe belirleniyor...
    ypos=0; // Başlangıçta bütün Matrix Effect objeleri karakterlerini yazmaya en yukarıdan başlar...
    xpos=random(0,width); //Düzlemde rasgele bir x pozisyonu belirlenir
    character=char(int(random(35,122))); //Rasgele bir karakter belirlenir. (random() fonksiyonunun dönüş değeri float olduğu için önce int'e sonra karaktere dönüşür)
    colorr=color(0,255,0);  //Başlangıç rengimiz yeşil (R,G,B)
}

  void display(){  //draw() fonksiyonunda sürekli olarak çağırdığımız bu fonksiyon her çağırıldığında bir karakterin görülmesini sağlayacaktır.
    character=char(int(random(35,122))); //Her çağırıldığında objenin rasgele karakteri belirlenir
    fill(colorr); //Karakter, objenin kendi renk üyesinin değerine boyanır
    if(isComplete(this)){ //isComplete() fonksiyonu ile Objenin kendisi için belirlenen mesafeyi tamamlayıp tamamlamadığı kontrol edilir.
      ypos=0; //Tamamlamışsa y pozisyonu sıfırlanr.(Tekrar yukarıdan başlaması için)
      xpos=random(0,width); //Rasgele x pozisyonu atanır
      range=random(0,height); //Rasgele mesafe belirlenir
    }
    // Eğer obje rasgele belirlenen mesafesini tamamlamamışsa y ekseni boyunca rasgele karakter çizmeye devam etmeli.
    textSize(12);
    text(this.character,xpos,ypos); //Karakter rasgele belirlenen 'x' pozisyonuna ve sürekli artan 'y' pozisyonuna text olarak yazılır.
    ypos+=speed; //Bir sonraki çağrılış için y pozisyonu değiştirilir
    ++count; //ERODE sayacı arttırılır.
    if(count%3==0){ // Ekrandaki  efektlerin kaybolmasını kontrol ettiğimiz mekanizma (Karakterler yazıldığı anda kaybolmasın.)
      filter(ERODE); //Karakterlerin yazıldıktan bir süre sonra kaybolmasını sağlayan filtre.
    }
  }
  boolean isComplete(MatrixEffect a){ // efektin kendisi için rasgele belirlenmiş pozisyonunu tamamlayıp tamamlamadığının kontrol edildiği şart bloğu.
    return ypos>=range;   
  }
  void check(int a){ //Her bir objenin yapılan girişlere duyarlı olması için renklerinin değiştirildiği fonksiyon.
  if(a==1){ //Giriş Başarılı ise açık mavi renk uygula
    colorr=color(100,120,255);
  }
  else if(a==2){//Giriş beklemesindeysek yeşil renk uygula (Objenin renk üyesinin değeri değiştiriliyor!)
     colorr=color(0,255,0);
  }
  else if(a==0){//Giriş başarısız ise renk kırmızı olmalı
  colorr=color(255,0,0);
  }
}
}
void serialEvent(Serial port){ //Arduino dan gelen bilgileri değerlendirdiğimiz fonksiyon.
if ( port.available() > 0) // Eğer port uygunsa-bilgi girişi varsa 
  {
 gelen=port.read(); //Gelen bilgi okunur  
 if(gelen==1){ //Giriş başarılı ise draw fonksiyonunda görsel değişim için control değişkeni değiştirilir.
     output.setText("ŞİFRE EŞLEŞTİ! \nKİLİT AÇILDI.."); 
     acilma.play(); 
     control=1;
 }
 else if(gelen==0){ //Giriş başarılı değilse draw fonksiyonunda görsel değişim için control değişkeni değiştirilir.(sıfırlanır)
   output.setText("HATALI GİRİŞ!\nLÜTFEN 4 HANELİ \nDOĞRU ŞİFREYİ GİRİNİZ..."); //arayüze
      hata.play();
      control=0;
   }
  }
}
