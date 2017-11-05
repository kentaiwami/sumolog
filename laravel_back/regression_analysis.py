from sklearn.datasets import load_iris
from sklearn.linear_model import LinearRegression
import numpy as np
from pandas import DataFrame


def hogehoge():
    iris = load_iris()
    X, y = iris.data[:-1], iris.target[:-1]

    t_X = DataFrame([0,1,2,3,4,5,6,7,8,9,10,11])
    t_y = DataFrame([20,19,20,21,19,18,18,19,20,20,21,18])
    # t_y = DataFrame([20, 19, 18, 16, 13, 10, 5, 2, 1, 1, 1, 0])

    regression = LinearRegression()
    regression.fit(t_X, t_y)

    px = np.arange(t_X.min(), t_X.max(), 0.01)[:,np.newaxis]

    # print(px)

    py = regression.predict(px)

    # plt.scatter(t_X, t_y, color='red')
    # plt.plot(px, py, color='blue')
    # plt.show()

    print(regression.coef_)
    print(regression.intercept_)

    x = 12
    print(regression.coef_*x + regression.intercept_)

    # 係数
    # print('Coefficients: \n', regression.coef_)
    # 切片
    # print('Intercept: \n', regression.intercept_)
    # スコア
    # print("score :", regression.score(t_X[0], t_y[0]))


def test():
    return 100


if __name__ == '__main__':
    test()