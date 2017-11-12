import numpy as np
import matplotlib.pyplot as plt


def test():
    x = np.array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    y = np.array([0.0, 0.8, 0.9, 0.1, -0.8, -1.0])
    z = np.polyfit(x, y, 4)

    print(z)
    print(type(z))

    # グラフ表示のテスト用
    p = np.poly1d(z)
    xp = np.linspace(-2, 6, 100)

    plt.plot(x, y, '+', xp, p(xp), '-')
    plt.ylim(-2, 2)
    plt.show()


if __name__ == '__main__':
    test()
