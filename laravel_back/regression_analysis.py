import sys
from sklearn.linear_model import LinearRegression
from pandas import DataFrame


def hogehoge():
    t_X = DataFrame([0,1,2,3,4,5,6,7,8,9,10,11])
    t_y = DataFrame([20,19,20,21,19,18,18,19,20,20,21,18])

    regression = LinearRegression()
    regression.fit(t_X, t_y)

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
    print(sys.argv[1])
    print(sys.argv[2])

if __name__ == '__main__':
    test()