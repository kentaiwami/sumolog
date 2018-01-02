import numpy as np
import matplotlib.pyplot as plt
import sys


def run_ra(y):
    y = [int(y_str) for y_str in y.split(',')]
    x = np.arange(len(y))
    z = np.polyfit(x, y, 4)
    p = np.poly1d(z)

    for _p in p:
        print(_p)

    # グラフ表示のテスト用
    # p = np.poly1d(z)
    # xp = np.linspace(-2, 6, 100)
    #
    # plt.plot(x, y, '+', xp, p(xp), '-')
    # plt.ylim(-2, 2)
    # plt.show()


if __name__ == '__main__':
    run_ra(sys.argv[1])
