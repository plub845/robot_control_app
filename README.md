# แอปพลิเคชันควบคุมหุ่นยนต์ Flutter

แอปพลิเคชัน Flutter นี้ถูกออกแบบมาเพื่อควบคุมหุ่นยนต์ของคุณอย่างมืออาชีพผ่านการเชื่อมต่อ **Bluetooth Classic** หรือ **WiFi (HTTP)** มันมีส่วนติดต่อผู้ใช้ที่ใช้งานง่าย พร้อมด้วยฟังก์ชันการควบคุมการเคลื่อนที่, การปรับความเร็ว, การสตรีมวิดีโอจากกล้อง (สำหรับ ESP32-CAM) และการสั่งงานโหมดพิเศษของหุ่นยนต์ โครงสร้างรองรับหลายภาษาและธีมที่ปรับแต่งได้ พร้อมการบันทึกการตั้งค่าทั้งหมดอย่างถาวร

## คุณสมบัติหลัก

* **การควบคุมการเคลื่อนที่ 5 ทิศทาง**: เดินหน้า, ถอยหลัง, เลี้ยวซ้าย, เลี้ยวขวา และหยุด (แบบกดค้างและปล่อย)
* **การปรับความเร็วแบบละเอียด**: แถบเลื่อนปรับค่า PWM สำหรับมอเตอร์
* **การเชื่อมต่อที่ยืดหยุ่น**:
    * **Bluetooth Classic**: รองรับการเชื่อมต่อกับโมดูล HC-05/06 บน Arduino หรือ Bluetooth ในตัวของ ESP32
    * **WiFi (HTTP)**: เหมาะอย่างยิ่งสำหรับ ESP32-CAM เพื่อการควบคุมและการสตรีมวิดีโอผ่านเครือข่าย
* **โหมดการทำงานของหุ่นยนต์**:
    * **โหมดควบคุมด้วยมือ**: ควบคุมการเคลื่อนที่โดยตรงผ่านแอป
    * **โหมดติดตามเส้น**: สั่งงานให้หุ่นยนต์เข้าสู่โหมดขับเคลื่อนอัตโนมัติ (ต้องมีการเขียนเฟิร์มแวร์รองรับ)
    * **มุมมองกล้อง**: แสดงผลวิดีโอสตรีมแบบ MJPEG จาก ESP32-CAM พร้อมการปรับแต่งคุณภาพของภาพ
* **การปรับแต่งอินเทอร์เฟซ**: สามารถเปิด/ปิดการแสดงผลของแถบเลื่อนความเร็ว, ปุ่มติดตามเส้น, และปุ่มกล้องได้
* **การตั้งค่ากล้องขั้นสูง**: กำหนดความกว้าง, ความสูง, ความสว่าง, การหมุน, และการซูมของภาพวิดีโอ รวมถึงประเภทสตรีม
* **รองรับหลายภาษา**: มีภาษาอังกฤษ, ไทย, และจีนให้เลือกใช้งาน
* **การปรับแต่งธีม**: เลือกธีมสว่าง, มืด, น้ำเงิน, หรือเขียว
* **การบันทึกการตั้งค่าถาวร**: การกำหนดค่าผู้ใช้ทั้งหมดจะถูกบันทึกโดยใช้ `shared_preferences`
* **การจัดการสิทธิ์อัตโนมัติ**: แอปจะร้องขอสิทธิ์ Bluetooth ที่จำเป็นเมื่อเริ่มต้น
* **การแจ้งเตือนข้อผิดพลาดที่ชัดเจน**: แสดงข้อความผิดพลาดสำหรับการเชื่อมต่อพร้อมตัวเลือกในการเปิดการตั้งค่าอุปกรณ์ที่เกี่ยวข้อง

---

## ส่วนที่ 1: เฟิร์มแวร์หุ่นยนต์ (Arduino / ESP32)

เลือกใช้โค้ดให้เหมาะสมกับฮาร์ดแวร์หุ่นยนต์ของคุณ

### 1.1 ESP32-CAM: WiFi Control & MJPEG Camera Stream

```cpp
#include "esp_camera.h"
#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <ArduinoJson.h>

#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27

#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

#define LED_GPIO_NUM       4 

const char* ssid = "ESP32_Robot_AP";
const char* password = "robotpassword";

WebServer server(80);

void setMotorSpeed(int speed) {
  Serial.print("Setting motor speed to: ");
  Serial.println(speed);
}

void moveForward() {
  Serial.println("Robot: Moving Forward!");
}

void moveBackward() {
  Serial.println("Robot: Moving Backward!");
}

void turnLeft() {
  Serial.println("Robot: Turning Left!");
}

void turnRight() {
  Serial.println("Robot: Turning Right!");
}

void stopMotors() {
  Serial.println("Robot: Stopping!");
}

void activateLineFollowMode() {
  Serial.println("Robot: Activating Line Follow Mode!");
}

void handleCommand(String jsonCommand) {
  Serial.print("Received command JSON: ");
  Serial.println(jsonCommand);

  StaticJsonDocument<256> doc;
  DeserializationError error = deserializeJson(doc, jsonCommand);

  if (error) {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return;
  }

  const char* action = doc["action"];
  int speed = doc["speed"] | 0;

  Serial.print("Action: "); Serial.println(action);
  Serial.print("Speed: "); Serial.println(speed);

  setMotorSpeed(speed);

  if (strcmp(action, "forward") == 0) {
    moveForward();
  } else if (strcmp(action, "backward") == 0) {
    moveBackward();
  } else if (strcmp(action, "left") == 0) {
    turnLeft();
  } else if (strcmp(action, "right") == 0) {
    turnRight();
  } else if (strcmp(action, "stop") == 0) {
    stopMotors();
  } else if (strcmp(action, "line") == 0) {
    activateLineFollowMode();
  } else if (strcmp(action, "camera") == 0) {
    Serial.println("Camera settings received.");
    sensor_t * s = esp_camera_sensor_get();
    if (s) {
      if (doc.containsKey("brightness")) {
          float brightness_val = doc["brightness"];
          s->set_brightness(s, (int8_t)(brightness_val * 4 - 2)); 
          Serial.printf("Set brightness to: %f\n", brightness_val);
      }
      if (doc.containsKey("contrast")) {
          float contrast_val = doc["contrast"];
          s->set_contrast(s, (int8_t)(contrast_val * 4 - 2));
          Serial.printf("Set contrast to: %f\n", contrast_val);
      }
    }
  }
}

void handle_jpg_stream(void) {
  WiFiClient client = server.client();
  if (!client.connected()) return;

  Serial.println("JPG Stream connected!");
  String response = "HTTP/1.1 200 OK\r\n";
  response += "Content-Type: multipart/x-mixed-replace; boundary=--frame\r\n";
  response += "\r\n";
  server.sendContent(response);

  camera_fb_t * fb = NULL;
  esp_err_t res = ESP_OK;
  size_t _jpg_buf_len = 0;
  uint8_t * _jpg_buf = NULL;
  char * part_buf[64];

  while (client.connected()) {
    fb = esp_camera_fb_get();
    if (!fb) {
      Serial.println("Camera capture failed");
      res = ESP_FAIL;
    } else {
      if (fb->format != PIXFORMAT_JPEG) {
        bool jpeg_converted = frame2jpg(fb, 80, &_jpg_buf, &_jpg_buf_len);
        esp_camera_fb_return(fb);
        fb = NULL;
        if (!jpeg_converted) {
          Serial.println("JPEG compression failed");
          res = ESP_FAIL;
        }
      } else {
        _jpg_buf = fb->buf;
        _jpg_buf_len = fb->len;
      }
    }
    if (res == ESP_OK) {
      sprintf((char *)part_buf, "--frame\r\nContent-Type: image/jpeg\r\nContent-Length: %u\r\n\r\n", _jpg_buf_len);
      server.sendContent((char *)part_buf);
      client.write(_jpg_buf, _jpg_buf_len);
      server.sendContent("\r\n");
    } else {
      Serial.println("Failed to get frame, sending empty response.");
      res = ESP_FAIL;
    }
    if (fb) {
      esp_camera_fb_return(fb);
      fb = NULL;
      _jpg_buf = NULL;
    } else if (_jpg_buf) {
      free(_jpg_buf);
      _jpg_buf = NULL;
    }
    if (res != ESP_OK) break;
  }
}

void handle_jpg_still() {
  camera_fb_t * fb = NULL;
  esp_err_t res = ESP_OK;
  size_t _jpg_buf_len = 0;
  uint8_t * _jpg_buf = NULL;

  fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Camera capture failed");
    server.send_P(404, "text/plain", "Camera capture failed");
    return;
  }

  if (fb->format != PIXFORMAT_JPEG) {
    bool jpeg_converted = frame2jpg(fb, 80, &_jpg_buf, &_jpg_buf_len);
    esp_camera_fb_return(fb);
    fb = NULL;
    if (!jpeg_converted) {
      Serial.println("JPEG compression failed");
      server.send_P(500, "text/plain", "JPEG compression failed");
      return;
    }
  } else {
    _jpg_buf = fb->buf;
    _jpg_buf_len = fb->len;
  }

  server.setContentLength(_jpg_buf_len);
  server.send_P(200, "image/jpeg", (const char *)_jpg_buf);

  if (fb) {
    esp_camera_fb_return(fb);
  } else if (_jpg_buf) {
    free(_jpg_buf);
  }
}

void setup() {
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println("\nESP32-CAM Robot Controller initializing...");

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_siod = SIOD_GPIO_NUM;
  config.pin_sioc = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG; 
  config.frame_size = FRAMESIZE_SVGA;
  config.jpeg_quality = 10;
  config.fb_count = 2;

  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x\n", err);
    return;
  }
  Serial.println("Camera initialized.");

  Serial.print("Setting up AP (Access Point)... ");
  WiFi.softAP(ssid, password);

  IPAddress myIP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(myIP);
  Serial.print("Connect to this WiFi network: ");
  Serial.println(ssid);
  Serial.println("Set your Flutter app's WiFi IP to: " + myIP.toString());

  server.on("/control", HTTP_POST, []() {
    Serial.println("Control command received via HTTP POST.");
    if (server.hasArg("plain")) {
      handleCommand(server.arg("plain"));
    }
    server.send(200, "text/plain", "OK");
  });

  server.on("/stream", HTTP_GET, handle_jpg_stream);
  server.on("/capture", HTTP_GET, handle_jpg_still);

  server.begin();
  Serial.println("HTTP server started.");
}

void loop() {
  server.handleClient();

### 1.2 Arduino: Bluetooth Control 

```cpp
#include <SoftwareSerial.h>
#include <ArduinoJson.h>

SoftwareSerial bluetoothSerial(10, 11); 

void setMotorSpeed(int speed) {
  Serial.print("Setting motor speed to: ");
  Serial.println(speed);
}

void moveForward() {
  Serial.println("Robot: Moving Forward!");
}

void moveBackward() {
  Serial.println("Robot: Moving Backward!");
}

void turnLeft() {
  Serial.println("Robot: Turning Left!");
}

void turnRight() {
  Serial.println("Robot: Turning Right!");
}

void stopMotors() {
  Serial.println("Robot: Stopping!");
}

void activateLineFollowMode() {
  Serial.println("Robot: Activating Line Follow Mode!");
}

void handleCommand(String jsonCommand) {
  Serial.print("Received Bluetooth JSON: ");
  Serial.println(jsonCommand);

  StaticJsonDocument<256> doc;
  DeserializationError error = deserializeJson(doc, jsonCommand);

  if (error) {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return;
  }

  const char* action = doc["action"];
  int speed = doc["speed"] | 0;

  Serial.print("Action: "); Serial.println(action);
  Serial.print("Speed: "); Serial.println(speed);

  setMotorSpeed(speed);

  if (strcmp(action, "forward") == 0) {
    moveForward();
  } else if (strcmp(action, "backward") == 0) {
    moveBackward();
  } else if (strcmp(action, "left") == 0) {
    turnLeft();
  } else if (strcmp(action, "right") == 0) {
    turnRight();
  } else if (strcmp(action, "stop") == 0) {
    stopMotors();
  } else if (strcmp(action, "line") == 0) {
    activateLineFollowMode();
  } else if (strcmp(action, "camera") == 0) {
    Serial.println("Camera mode requested (not applicable for Arduino Uno/Nano).");
  }
}

void setup() {
  Serial.begin(9600);
  Serial.println("Arduino Bluetooth Robot Controller Initializing...");

  bluetoothSerial.begin(9600);
  Serial.println("Bluetooth Serial started at 9600 baud.");
}

void loop() {
  if (bluetoothSerial.available()) {
    String command = bluetoothSerial.readStringUntil('\n');
    command.trim();
    handleCommand(command);
  }
}
1.3 ESP32 พร้อม Bluetooth Classic ในตัว
C++

#include "BluetoothSerial.h"
#include <ArduinoJson.h>

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to enable it.
#endif

BluetoothSerial SerialBT;

void setMotorSpeed(int speed) {
  Serial.print("Setting motor speed to: ");
  Serial.println(speed);
}

void moveForward() {
  Serial.println("Robot: Moving Forward!");
}

void moveBackward() {
  Serial.println("Robot: Moving Backward!");
}

void turnLeft() {
  Serial.println("Robot: Turning Left!");
}

void turnRight() {
  Serial.println("Robot: Turning Right!");
}

void stopMotors() {
  Serial.println("Robot: Stopping!");
}

void activateLineFollowMode() {
  Serial.println("Robot: Activating Line Follow Mode!");
}

void handleCommand(String jsonCommand) {
  Serial.print("Received Bluetooth JSON: ");
  Serial.println(jsonCommand);

  StaticJsonDocument<256> doc;
  DeserializationError error = deserializeJson(doc, jsonCommand);

  if (error) {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return;
  }

  const char* action = doc["action"];
  int speed = doc["speed"] | 0;

  Serial.print("Action: "); Serial.println(action);
  Serial.print("Speed: "); Serial.println(speed);

  setMotorSpeed(speed);

  if (strcmp(action, "forward") == 0) {
    moveForward();
  } else if (strcmp(action, "backward") == 0) {
    moveBackward();
  } else if (strcmp(action, "left") == 0) {
    turnLeft();
  } else if (strcmp(action, "right") == 0) {
    turnRight();
  } else if (strcmp(action, "stop") == 0) {
    stopMotors();
  } else if (strcmp(action, "line") == 0) {
    activateLineFollowMode();
  } else if (strcmp(action, "camera") == 0) {
    Serial.println("Camera mode requested (not applicable for non-ESP32-CAM).");
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println("\nESP32 Bluetooth Robot Controller initializing...");

  SerialBT.begin("ESP32_Robot");
  Serial.println("Bluetooth device started, named 'ESP32_Robot'.");
}

void loop() {
  if (SerialBT.available()) {
    String command = SerialBT.readStringUntil('\n');
    command.trim();
    handleCommand(command);
  }
}