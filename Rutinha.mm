//BIBLIOTECAS
  #include <HCSR04.h>
  #include <LiquidCrystal.h>
  #include <SPI.h> // needed in Arduino 0019 or later
  #include <Ethernet.h>
  #include <Twitter.h>
//.

//Defines/Pins
  #define TRIGGER_PIN  8
  #define ECHO_PIN     10
  #define UMIDADE      A0
  #define LDR          A1
  #define TEMPERATURA  A2
  #define RANDOM       0

//lcd(2,3,4,5,6,7)
  const int rs = 2, en = 3, d4 = 4, d5 = 5, d6 = 6, d7 = 7;
  LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

//declarando sensor ultrasonico
  UltraSonicDistanceSensor distanceSensor(TRIGGER_PIN, ECHO_PIN);
  double distance;

//RAW sensors
  float umidadeRAW;
  float iluminacaoRAW;
  float temperaturaRAW;

//NOVO DELAY(Wait)
  //Marca o tempo que o pino ligou/desligou pela ultima vez.
  const byte waitQtd = 3;
  unsigned long LastWaitToggleTime[waitQtd];

  // Estado atual da função wait; true => Ligado; false => Desligado. 
  bool IsWaitOn[waitQtd];

//MENSAGENS
  byte MSGAttempts = 0;
  char DEUSMEAJUDA[15];

//.

void setup()
{
  //RandomSeed
    randomSeed(analogRead(RANDOM));
  //Inicializando wait
    for(byte i = 0;i < waitQtd;i++)
    {
      LastWaitToggleTime[i] = 0;
      IsWaitOn[i] = true;
    }

  //Serial de Testes
    Serial.begin(9600);
    Serial.println("Lendo dados...");

  pinMode(UMIDADE, INPUT);          // Inicializa o pino de umidade
  lcd.begin(16,2);                  // Inicializa o LCD( linhas, colunas)
}

void loop()
{
  //LEITURA
    umidadeRAW = 1024 - analogRead(UMIDADE);
    iluminacaoRAW = 1024 - analogRead(LDR);
    temperaturaRAW = analogRead(TEMPERATURA);
    //float temperaturaRAW = analogRead(TEMPERATURA);
    //
    //Sensor ultrasonico...
      //long microsec = ultrasonico.timing(); //Leitura de MS do sensor ultrassonico
      //float distanciaObjetoCM = ultrasonico.convert(microsec, Ultrasonic::CM); //Distancia em CM do sensor
      distance = distanceSensor.measureDistanceCm();
    //.
  //.

  /*
    //Processamento de mensagens
      int umidade = testLevels(umidadeRAW);
      int iluminacao = testLevels(iluminacaoRAW);
      //int temperatura = testLevels(temperaturaRAW);
      int processLevels[3/*falta temperatura/] = {umidade,iluminacao/*,temperatura/};
    //.
  */

  //LCD...
  
    wait(500, 0);
    if(IsWaitOn[0])
    {
      lcd.clear();
      lcd.setCursor(0,0);
      if(distance < 100)
      {
        lcd.print("OLA!");
      }

      
      lcd.setCursor(0,1);
      if(iluminacaoRAW > 500)
      {
        lcd.print("Que luz gostosa!");
      }
      else
      {
        lcd.print("Escuro...medo...");
      }
    }
  //.

  wait(20000, 2);
  if(IsWaitOn[2])
  {
    //TESTES:
      //SERIAL DE UMIDADE:
      // < 200 = seco
      // < 600 = moderado
      // < 1024 = umido
      Serial.print("\nUmidade:");
      Serial.print(umidadeRAW);

      
      //SERIAL DE DISTANCIA
      Serial.print("\nDistancia de um objeto: ");
      Serial.print(distance);
      
      
      //SERIAL DE ILUMINACAO
      Serial.print("\nQuantidade de iluminacao: ");
      Serial.print(iluminacaoRAW);
      Serial.print("\n\n\n");
    //.
  }

  Mensagem_Escolhida();
  wait((20000*1), 1);
  if(IsWaitOn[1])
  {
    tweet();
  }
}

// MENSAGENS PERFEITA... T^T
  void Mensagem_Escolhida() //PERFEITA DA VONTADE DE CHORA
  {
    float sinal;
    float umidadeMedia = 500;
    const int maxTEXTS = 11;
    byte row;
    byte min,max,randMessagePercent;
    char msg[3][maxTEXTS][15]=
    {
      /*UMIDADE/HUMILDADE*/
      {
        "Umidade 0","Umidade 10","Umidade 20","Umidade 30","Umidade 40","Umidade 50","Umidade 60","Umidade 70","Umidade 80","Umidade 90","Umidade 100"
      },
      /*ILUMINAÇÃO*/
      {
        "*Iluminacao 0","Iluminacao 10","*Iluminacao 20","*Iluminacao 30","Iluminacao 40","Iluminacao 50","*Iluminacao 60","Iluminacao 70","Iluminacao 80","Iluminacao 90","*Iluminacao 100"
      },
      /*TEMPERATURA*/
      {
        "Temperatura 0","*Temperatura 10","Temperatura 20","*Temperatura 30","*Temperatura 40","Temperatura 50","*Temperatura 60","Temperatura 70","Temperatura 80","Temperatura 90","Temperatura 100"
      }
    };

    if(umidadeRAW > iluminacaoRAW && umidadeRAW > temperaturaRAW)
    {
      row = 0;
      sinal = umidadeRAW;
    }
    else if(iluminacaoRAW > umidadeRAW && iluminacaoRAW > temperaturaRAW)
    {
      row = 1;
      sinal = iluminacaoRAW;
    }
    else
    {
      row = 2;
      sinal = temperaturaRAW;
    }
    min = sinal/10.24 - 10;
    max = sinal/10.24 + 10;
    
    
    randMessagePercent = random(min, max); 
    if(umidadeRAW < umidadeMedia)
    {
      // Messagem revoltada
      if(msg[row][(int)(randMessagePercent * (maxTEXTS/100))][0] == '*')
      {
        strcpy(DEUSMEAJUDA, msg[row][(int)(randMessagePercent * (maxTEXTS/100))]);
      }
    }
    else
    {
      // Mensagem deboa
      if(msg[row][(int)(randMessagePercent * (maxTEXTS/100))][0] != '*')
      {
        strcpy(DEUSMEAJUDA, msg[row][(int)(randMessagePercent * (maxTEXTS/100))]);
      }
    }
    MSGAttempts++;
    if(MSGAttempts >= 10)
    {
      strcpy(DEUSMEAJUDA, msg[row][(int)(randMessagePercent * (maxTEXTS/100))]);
      MSGAttempts = 0;
    }
  }
//.

void wait(const unsigned long WAITTogglePeriod, const byte waitNum) //WAITTogglePeriod = tempo que irá ficar desligado/ligado
{
  if(millis() - LastWaitToggleTime[waitNum] >= WAITTogglePeriod)
  {
    IsWaitOn[waitNum] = true;
    LastWaitToggleTime[waitNum] = millis();
  }
  else
  {
    IsWaitOn[waitNum] = false;
  }
}


// int testLevels(float dado)
// {
//   // < 200 = Baixo
//   // < 600 = Médio
//   // < 1024 = Alto

//   return (dado <= 200)?0:(dado <= 600)?1:2;
//   /*  Ternario para If(dado<200)
//                       If(dado<600)
//                         If(dado < 1024)
//   */
// }

void tweet()
{
  // Ethernet Shield Settings
    byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

  // If you don't specify the IP address, DHCP is used(only in Arduino 1.0 or later).
    byte ip[] = { 192, 168, 2, 250 };

  // Your Token to Tweet (get it from http://arduino-tweet.appspot.com/)
    Twitter twitter("1009106678091010050-sRts8sqbq9YVFraxtfVr7i2ah1HHmN");

  // Message to post
    //char msg[] = *DEUSMEAJUDA;
    //Mensagem_Escolhida().toCharArray(msg, 50); <- para mensagem perfeita T^T
  //.

  Ethernet.begin(mac/*, ip*/);
  // or you can use DHCP for autoomatic IP address configuration.
  // Ethernet.begin(mac);
  
  Serial.println("Conectando ...");
  if (twitter.post(DEUSMEAJUDA)) {
    // Specify &Serial to output received response to Serial.
    // If no output is required, you can just omit the argument, e.g.
    // int status = twitter.wait();
    int status = twitter.wait(&Serial);
    if (status == 200) {
      Serial.println("Mensagem enviada.");
    } else {
      Serial.print("failed : code ");
      Serial.println(status);
    }
  } else {
    Serial.println("Falha na conexão.");
  }
}