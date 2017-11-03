import RPi.GPIO as GPIO
import time
import urllib.request
import json
import queue
from collections import Counter


# change these as desired - they're the pins connected from the
# SPI port on the ADC to the Cobbler
SPICLK = 11
SPIMISO = 9
SPIMOSI = 10
SPICS = 8
mq7_dpin = 26
mq7_apin = 0

SMOKE_ID = '0'

# port init
def init():
    GPIO.setwarnings(False)
    GPIO.cleanup()  # clean up at the end of your script
    GPIO.setmode(GPIO.BCM)  # to specify whilch pin numbering system
    # set up the SPI interface pins
    GPIO.setup(SPIMOSI, GPIO.OUT)
    GPIO.setup(SPIMISO, GPIO.IN)
    GPIO.setup(SPICLK, GPIO.OUT)
    GPIO.setup(SPICS, GPIO.OUT)
    GPIO.setup(mq7_dpin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)


# read SPI data from MCP3008(or MCP3204) chip,8 possible adc's (0 thru 7)
def readadc(adcnum, clockpin, mosipin, misopin, cspin):
    if ((adcnum > 7) or (adcnum < 0)):
        return -1
    GPIO.output(cspin, True)

    GPIO.output(clockpin, False)  # start clock low
    GPIO.output(cspin, False)  # bring CS low

    commandout = adcnum
    commandout |= 0x18  # start bit + single-ended bit
    commandout <<= 3  # we only need to send 5 bits here
    for i in range(5):
        if (commandout & 0x80):
            GPIO.output(mosipin, True)
        else:
            GPIO.output(mosipin, False)
        commandout <<= 1
        GPIO.output(clockpin, True)
        GPIO.output(clockpin, False)

    adcout = 0
    # read in one empty bit, one null bit and 10 ADC bits
    for i in range(12):
        GPIO.output(clockpin, True)
        GPIO.output(clockpin, False)
        adcout <<= 1
        if (GPIO.input(misopin)):
            adcout |= 0x1

    GPIO.output(cspin, True)

    adcout >>= 1  # first bit is 'null' so drop it
    return adcout


# main ioop
def main():
    co_q = queue.Queue()
    co_difference_q = queue.Queue()

    started_flag = False
    hoge_flag = False

    co_minus_count = 90
    co_level_count = 30

    co_difference_threshold = 0.5
    co_error_range = 0.1

    # f = open('hoge.csv', 'a')
    init()
    print("please wait...")

    time.sleep(20)

    while True:
        COlevel = readadc(mq7_apin, SPICLK, SPIMOSI, SPIMISO, SPICS)

        # if GPIO.input(mq7_dpin):
        #     print("CO not leak")
        #     time.sleep(0.5)
        # else:

        # print("Current CO AD vaule = " + str("%.2f" % ((COlevel / 1024.) * 5)) + " V")

        co_percent = (COlevel / 1024.) * 100

        print(co_percent)

        # キューのサイズを超えないようにCO値を格納
        if co_q.qsize() < co_level_count:
            co_q.put(co_percent)
        else:
            co_q.get()
            co_q.put(co_percent)

        ave = sum(list(co_q.queue)) / co_q.qsize()

        co_difference = co_percent - ave

        # CO値の差分が閾値を超えたらsmoke作成APIを叩く
        if co_difference > co_difference_threshold and not started_flag:
            run_api(True)
            started_flag = True
            co_q.queue.clear()
            print('start', ave, co_percent)

        # キューのサイズを超えないようにCO差分値を格納
        if co_difference_q.qsize() < co_minus_count:
            co_difference_q.put(co_difference)
        else:
            co_difference_q.get()
            co_difference_q.put(co_difference)

        # CO差分値が負になっているリストを生成
        co_difference_minus = [co_difference for co_difference in list(co_difference_q.queue) if
                               float(co_difference) < 0.0]

        # 「CO差分値のリストが指定した長さを超えている」または閾値を超えていたらsmoke終了のAPIを叩く
        # if ((len(co_difference_minus) >= co_minus_count) or (
        #     co_percent - ave) < -co_difference_threshold) and started_flag:
        #     hoge_flag = True
        #     print('****** minus catch ******')

        # if abs(ave - co_percent) <= co_error_range and hoge_flag:
        # TODO 喫煙を開始していてかつ同じ値が一定数以上連続した場合
        co_q_list = list(co_q.queue)
        if len(co_q_list) == 0:
            word, cnt = '', 0
        else:
            word, cnt = hogehoge(list(co_q.queue))

        if cnt > co_level_count-5 and started_flag:
            run_api(False)
            started_flag = False
            print('end', ave, co_percent)


        print("Current CO density is:" + str("%.2f" % ((COlevel / 1024.) * 100)) + " %")
        time.sleep(1)



def run_api(create_flag):
    global SMOKE_ID

    base_url = 'https://kentaiwami.jp/sumolog/index.php/api/smoke/'
    # TODO uuidを連携するコードは後ほど
    obj = {
        'uuid': 'hoge'
    }

    if create_flag:
        api_url = base_url + ''
        method = 'POST'

    else:
        api_url = base_url + str(SMOKE_ID)
        method = 'PUT'

    json_data = json.dumps(obj).encode("utf-8")
    headers = {"Content-Type": "application/json"}

    request = urllib.request.Request(api_url, data=json_data, headers=headers, method=method)
    response = urllib.request.urlopen(request)
    response_body = response.read().decode("utf-8")
    result_objs = json.loads(response_body.split('\n')[0])

    SMOKE_ID = result_objs['smoke_id']


def test():
    f = open('test_data/5.txt')
    lines = f.read().split('\n')
    f.close()

    co_q = queue.Queue()
    co_difference_q = queue.Queue()

    started_flag = False
    hoge_flag = False

    # 5:30,30  4:30,30, 3:none  2:30,30
    co_minus_count = 30
    co_level_count = 30

    co_difference_threshold = 0.5
    co_error_range = 0.19

    for index, line in enumerate(lines):
        co_percent = float(line)

        # print(line, index+1)

        # キューのサイズを超えないようにCO値を格納
        if co_q.qsize() < co_level_count:
            co_q.put(co_percent)
        else:
            co_q.get()
            co_q.put(co_percent)

        ave = sum(list(co_q.queue)) / co_q.qsize()

        co_difference = co_percent - ave

        # CO値の差分が閾値を超えたらsmoke作成APIを叩く
        if co_difference > co_difference_threshold and not started_flag:
            run_api(True)
            started_flag = True
            co_q.queue.clear()
            print('start', ave, line, index+1)

        # キューのサイズを超えないようにCO差分値を格納
        if co_difference_q.qsize() < co_minus_count:
            co_difference_q.put(co_difference)
        else:
            co_difference_q.get()
            co_difference_q.put(co_difference)

        # CO差分値が負になっているリストを生成
        co_difference_minus = [co_difference for co_difference in list(co_difference_q.queue) if float(co_difference) < 0.0]

        # if started_flag and abs(ave - co_level) <= 0.1:

        # 「CO差分値のリストが指定した長さを超えている」または閾値を超えていたらsmoke終了のAPIを叩く
        # if ((len(co_difference_minus) >= co_minus_count) or (co_percent-ave) < -co_difference_threshold) and started_flag:
        #     hoge_flag= True
        #     print('****** minus catch ******')
        #     print(index)

        # if abs(ave - co_percent) <= co_error_range and hoge_flag and started_flag:

        co_q_list = list(co_q.queue)
        if len(co_q_list) == 0:
            word, cnt = '', 0
        else:
            word, cnt = hogehoge(list(co_q.queue))

        if cnt > 30 and started_flag:
            run_api(False)
            started_flag = False
            print('end', ave, line, index+1)


def hogehoge(data):
    counter = Counter(data)

    for word, cnt in counter.most_common():
        print(word, cnt)
        return word, cnt


def po():
    q = queue.Queue()
    q.put(10)

    print(q.queue)

    q.queue.clear()

    print(len(list(q.queue)))

if __name__ == '__main__':
    # po()
    # hogehoge()
    # test()
    try:
        main()
        pass
    except KeyboardInterrupt:
        pass

GPIO.cleanup()
