from matplotlib.colors import LinearSegmentedColormap, ListedColormap, \
                              ColorConverter
import numpy as np


def calipso_colormap():
    CALIPSO_RGB = [
        (0, 0.16862745,  0.50196078),
        (0, 0.16862745,  0.66666667),
        (0, 0.16862745, 0.6667),
        (0, 0.50196078, 1),
        (0, 0.66666667, 1),
        (0, 0.83529412, 1),
        (0, 1, 1),
        (0, 1, 0.83529412),
        (0, 1, 0.66666667),
        (0, 0.50196078, 0.50196078),
        (0, 0.66666667, 0.33333333),
        (1, 1, 0.47843137),
        (1, 1, 0),
        (1, 0.83529412, 0),
        (1, 0.66666667, 0),
        (1, 0.50196078, 0),
        (1, 0.33333333, 0),
        (1, 0, 0),
        (1, 0.16862745, 0.33333333),
        (1, 0.33333333, 0.50196078),
        (1, 0.50196078, 0.66666667),
        (0.78431373, 0.78431373, 0.78431373),
        (0.60784314, 0.60784314, 0.60784314),
        (0.50980392, 0.50980392, 0.50980392),
        (0.39215686, 0.39215686, 0.39215686),
        (0.2745098, 0.2745098, 0.2745098)
    ]

    nbins = 255
    CALIPSO_CMAP = LinearSegmentedColormap.from_list(
        'calipso', CALIPSO_RGB, N=nbins)

    return CALIPSO_CMAP


def chiljet_colormap():

    chiljet_rgb = [
        (0.871093750000000, 0.871093750000000, 0.871093750000000),
        (0.816406250000000, 0.816406250000000, 0.886718750000000),
        (0.761718750000000, 0.761718750000000, 0.906250000000000),
        (0.707031250000000, 0.707031250000000, 0.921875000000000),
        (0.656250000000000, 0.656250000000000, 0.941406250000000),
        (0.601562500000000, 0.601562500000000, 0.957031250000000),
        (0.546875000000000, 0.546875000000000, 0.976562500000000),
        (0.496093750000000, 0.496093750000000, 0.996093750000000),
        (0.433593750000000, 0.433593750000000, 0.996093750000000),
        (0.371093750000000, 0.371093750000000, 0.996093750000000),
        (0.308593750000000, 0.308593750000000, 0.996093750000000),
        (0.246093750000000, 0.246093750000000, 0.996093750000000),
        (0.183593750000000, 0.183593750000000, 0.996093750000000),
        (0.121093750000000, 0.121093750000000, 0.996093750000000),
        (0.0585937500000000, 0.0585937500000000, 0.996093750000000),
        (0, 0, 0.996093750000000),
        (0, 0.0742187500000000, 0.949218750000000),
        (0, 0.152343750000000, 0.902343750000000),
        (0, 0.230468750000000, 0.855468750000000),
        (0, 0.308593750000000, 0.808593750000000),
        (0, 0.386718750000000, 0.761718750000000),
        (0, 0.464843750000000, 0.714843750000000),
        (0, 0.542968750000000, 0.667968750000000),
        (0, 0.621093750000000, 0.621093750000000),
        (0, 0.667968750000000, 0.542968750000000),
        (0, 0.714843750000000, 0.464843750000000),
        (0, 0.761718750000000, 0.386718750000000),
        (0, 0.808593750000000, 0.308593750000000),
        (0, 0.855468750000000, 0.230468750000000),
        (0, 0.902343750000000, 0.152343750000000),
        (0, 0.949218750000000, 0.0742187500000000),
        (0, 0.996093750000000, 0),
        (0.121093750000000, 0.996093750000000, 0),
        (0.246093750000000, 0.996093750000000, 0),
        (0.371093750000000, 0.996093750000000, 0),
        (0.496093750000000, 0.996093750000000, 0),
        (0.621093750000000, 0.996093750000000, 0),
        (0.746093750000000, 0.996093750000000, 0),
        (0.871093750000000, 0.996093750000000, 0),
        (0.996093750000000, 0.996093750000000, 0),
        (0.996093750000000, 0.933593750000000, 0),
        (0.996093750000000, 0.871093750000000, 0),
        (0.996093750000000, 0.808593750000000, 0),
        (0.996093750000000, 0.746093750000000, 0),
        (0.996093750000000, 0.683593750000000, 0),
        (0.996093750000000, 0.621093750000000, 0),
        (0.996093750000000, 0.558593750000000, 0),
        (0.996093750000000, 0.496093750000000, 0),
        (0.996093750000000, 0.433593750000000, 0),
        (0.996093750000000, 0.371093750000000, 0),
        (0.996093750000000, 0.308593750000000, 0),
        (0.996093750000000, 0.246093750000000, 0),
        (0.996093750000000, 0.183593750000000, 0),
        (0.996093750000000, 0.121093750000000, 0),
        (0.996093750000000, 0.0585937500000000, 0),
        (0.996093750000000, 0, 0),
        (0.933593750000000, 0, 0.0585937500000000),
        (0.871093750000000, 0, 0.121093750000000),
        (0.808593750000000, 0, 0.183593750000000),
        (0.746093750000000, 0, 0.246093750000000),
        (0.683593750000000, 0, 0.308593750000000),
        (0.621093750000000, 0, 0.371093750000000),
        (0.558593750000000, 0, 0.433593750000000),
        (0.496093750000000, 0, 0.496093750000000)]

    nbins = 255
    chiljet_cmap = LinearSegmentedColormap.from_list(
        'chiljet', chiljet_rgb, N=nbins)

    return chiljet_cmap


def target_classification_colormap():

    tc_rgb = [
                [1, 1, 1],
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

    TC_CMAP = ListedColormap(tc_rgb)
    return TC_CMAP


def signal_status_colormap():

    ss_rgb = [[0, 0.5020, 1],
              [1, 0, 0.5020],
              [0.5020, 0.5020, 0.5020]]

    SS_CMAP = ListedColormap(ss_rgb)
    return SS_CMAP


def make_colormap(seq):
    """Return a LinearSegmentedColormap
    seq: a sequence of floats and RGB-tuples. The floats should be increasing
    and in the interval (0,1).
    """
    seq = [(None,) * 3, 0.0] + list(seq) + [1.0, (None,) * 3]
    cdict = {'red': [], 'green': [], 'blue': []}
    for i, item in enumerate(seq):
        if isinstance(item, float):
            r1, g1, b1 = seq[i - 1]
            r2, g2, b2 = seq[i + 1]
            cdict['red'].append([item, r1, r2])
            cdict['green'].append([item, g1, g2])
            cdict['blue'].append([item, b1, b2])
    return LinearSegmentedColormap('CustomMap', cdict)


def eleni_colormap():
    c = ColorConverter().to_rgb
    cmap = make_colormap([
        c('lightskyblue'), c('dodgerblue'), 0.1,
        c('dodgerblue'), c('teal'), 0.2,
        c('teal'), c('limegreen'), 0.3,
        c('limegreen'), c('yellow'), 0.4,
        c('yellow'), c('orange'), 0.5,
        c('orange'), c('orangered'), 0.6,
        c('orangered'), c('red'), 0.7,
        c('red'), c('firebrick'), 0.8,
        c('firebrick'), c('darkred'), 0.9,
        c('darkred'), c('k')])
    cmap.set_bad(color='white', alpha=1)
    return cmap


def load_colormap(name='chiljet'):
    """
    load colormap according to input colormap name.

    Params
    ------
    name: str
        colormap name.
        - 'chiljet'
        - 'eleni'
        - 'CALIPSO'
    Return
    ------
    cmap: matplotlib colormap
    """

    if name == 'chiljet':
        cmap = chiljet_colormap()
    elif name == 'eleni':
        cmap = eleni_colormap()
    elif name == 'CALIPSO':
        cmap = CALIPSO_colormap()
    else:
        raise RuntimeWarning('Unknown colormap: {0}'.format(name))

    return cmap


def Test():
    print("-------------------Test---------------------")

    import numpy as np
    import matplotlib.pyplot as plt

    x = np.random.random((40, 40))
    y = np.random.random((40, 40))
    X, Y = np.meshgrid(x, y)
    Z = np.exp(-2*(X**2 + Y**2))

    plt.contourf(Z, level=40, cmap=eleni_colormap())
    plt.colorbar()
    plt.show()

    # fig = plt.figure(figsize=[15, 5])
    # ax = fig.add_subplot(111)

    # pc = ax.pcolormesh(
    #     np.random.rand(10, 10)*12,
    #     vmin=0, vmax=11, cmap=target_classification_colormap())

    # cbar = plt.colorbar(pc, ticks=[(np.arange(0, 12) + 0.5)*11/12])
    # cbar.ax.set_yticklabels(['No signal',
    #                          'Clean atmosphere',
    #                          'Non-typed particles/low conc.',
    #                          'Aerosol: small',
    #                          'Aerosol: large, spherical',
    #                          'Aerosol: mixture, partly non-spherical',
    #                          'Aerosol: large, non-spherical',
    #                          'Cloud: non-typed',
    #                          'Cloud: water droplets',
    #                          'Cloud: likely water droplets',
    #                          'Cloud: ice crystals',
    #                          'Cloud: likely ice crystals'])
    # plt.show()


def make_colormap(seq):
    """Return a LinearSegmentedColormap
    seq: a sequence of floats and RGB-tuples. The floats should be increasing
    and in the interval (0,1).
    """
    seq = [(None,) * 3, 0.0] + list(seq) + [1.0, (None,) * 3]
    cdict = {'red': [], 'green': [], 'blue': []}
    for i, item in enumerate(seq):
        if isinstance(item, float):
            r1, g1, b1 = seq[i - 1]
            r2, g2, b2 = seq[i + 1]
            cdict['red'].append([item, r1, r2])
            cdict['green'].append([item, g1, g2])
            cdict['blue'].append([item, b1, b2])
    return matplotlib.colors.LinearSegmentedColormap('CustomMap', cdict)

def eleni_colormap():
    c = matplotlib.colors.ColorConverter().to_rgb 
    cmap=eleni_colormap([c('lightskyblue'),c('dodgerblue'), 0.1,
                          c('dodgerblue'),c('teal'), 0.2,
                          c('teal'),c('limegreen'), 0.3,
                          c('limegreen'),c('yellow'), 0.4,
                          c('yellow'), c('orange'), 0.5,
                          c('orange'),c('orangered'), 0.6,
                          c('orangered'), c('red'), 0.7,
                          c('red'), c('firebrick'), 0.8,
                          c('firebrick'),c('darkred'), 0.9,
                          c('darkred'),c('k')])
    cmap.set_bad(color='white', alpha=1)
    return cmap

def main():
    Test()


if __name__ == '__main__':
    main()
