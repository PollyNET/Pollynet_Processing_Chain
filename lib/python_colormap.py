from matplotlib.colors import LinearSegmentedColormap, ListedColormap
import numpy as np

def calipso_colormap():
    CALIPSO_RGB = [
    (0,0.16862745,0.50196078) 
    ,(0,0.16862745,0.66666667)
    ,(0,0.16862745,0.6667)
    ,(0,0.50196078,1)
    ,(0,0.66666667,1)
    ,(0,0.83529412,1)
    ,(0,1,1)
    ,(0,1,0.83529412)
    ,(0,1,0.66666667)
    ,(0,0.50196078,0.50196078)
    ,(0,0.66666667,0.33333333)
    ,(1,1,0.47843137)
    ,(1,1,0)
    ,(1,0.83529412,0)
    ,(1,0.66666667,0)
    ,(1,0.50196078,0)
    ,(1,0.33333333,0)
    ,(1,0,0)
    ,(1,0.16862745,0.33333333)
    ,(1,0.33333333,0.50196078)
    ,(1,0.50196078,0.66666667)
    ,(0.78431373,0.78431373,0.78431373)
    ,(0.60784314,0.60784314,0.60784314)
    ,(0.50980392,0.50980392,0.50980392)
    ,(0.39215686,0.39215686,0.39215686)
    ,(0.2745098,0.2745098,0.2745098)
    ]

    nbins = 255
    CALIPSO_CMAP = LinearSegmentedColormap.from_list('calipso', CALIPSO_RGB, N=nbins)

    return CALIPSO_CMAP

def target_classification_colormap():
    
    tc_rgb = [[1, 1, 1], 
              [0.9, 0.9, 0.9], 
              [0.6, 0.6, 0.6], 
              [221./255., 204./255., 119./255.], 
              [231./255., 109./255., 46./255.], 
              [136./255., 34./255., 0], 
              [0, 0, 0], 
              [120./255., 28./255., 129./255.], 
              [58./255., 137./255., 201./255.], 
              [180./255., 221./255., 247./255.], 
              [17./255., 119./255., 51./255.], 
              [134./255., 187./255., 106./255.]]
    # red = np.array([1, 0.9, 0.6, 221/255, 231/255, 136/255, 0, 120/255, 58/255, 180/255, 17/255, 134/255])
    # green = np.array([1, 0.9, 0.6, 204/255, 109/255, 34/255, 0, 128/255, 137/255, 221/255, 119/255, 119/255, 187/255])
    # blue = np.array([1, 0.9, 0.6, 119/255, 46/255, 0, 0, 129/255, 201/255, 247/255, 51/255, 106/255])
    # tc_rgb = np.array([red, green, blue]).T

    # tc_rgb = [[0.9, 0.9, 0.9], [0.6, 0.6, 0.6], [0,0,0]]

    TC_CMAP = ListedColormap(tc_rgb)
    return TC_CMAP


def signal_status_colormap():
    
    ss_rgb = [[0, 0.5020, 1], 
              [1, 0, 0.5020], 
              [0.5020, 0.5020, 0.5020]]

    SS_CMAP = ListedColormap(ss_rgb)
    return SS_CMAP

def Test():
    print("-------------------Test---------------------")

    import numpy as np
    import matplotlib.pyplot as plt

    # x = np.random.random((10, 10))
    # y = np.random.random((10, 10))
    # X, Y = np.meshgrid(x, y)
    # Z = np.exp(-2*(X**2 + Y**2))

    # plt.contourf(Z, level=20, cmap=calipso_colormap())
    # plt.colorbar()
    # plt.show()

    fig = plt.figure(figsize=[15, 5])
    ax = fig.add_subplot(111)

    pc = ax.pcolormesh(np.random.rand(10, 10)*12, vmin=0, vmax=11, cmap=target_classification_colormap())

    cbar = plt.colorbar(pc, ticks=[(np.arange(0, 12) + 0.5)*11/12])
    cbar.ax.set_yticklabels(['No signal',
                             'Clean atmosphere',
                             'Non-typed particles/low conc.',
                             'Aerosol: small',
                             'Aerosol: large, spherical',
                             'Aerosol: mixture, partly non-spherical',
                             'Aerosol: large, non-spherical',
                             'Cloud: non-typed',
                             'Cloud: water droplets',
                             'Cloud: likely water droplets',
                             'Cloud: ice crystals',
                             'Cloud: likely ice crystals'])

    plt.savefig('temp.png')
    plt.close()

def main():
    Test()

if __name__ == '__main__':
    main()