from matplotlib.colors import LinearSegmentedColormap, ListedColormap, \
                              ColorConverter
import numpy as np


def labivew_colormap():
    Labview_RGB = [(0, 0.262745098039216, 0.862745098039216),
        (0, 0.262745098039216, 0.862745098039216),
        (0, 0.262745098039216, 0.858823529411765),
        (0, 0.266666666666667, 0.858823529411765),
        (0, 0.270588235294118, 0.858823529411765),
        (0, 0.274509803921569, 0.858823529411765),
        (0, 0.278431372549020, 0.854901960784314),
        (0, 0.282352941176471, 0.854901960784314),
        (0, 0.282352941176471, 0.854901960784314),
        (0, 0.286274509803922, 0.854901960784314),
        (0, 0.290196078431373, 0.854901960784314),
        (0, 0.298039215686275, 0.850980392156863),
        (0, 0.301960784313725, 0.850980392156863),
        (0, 0.305882352941177, 0.850980392156863),
        (0, 0.309803921568627, 0.850980392156863),
        (0, 0.313725490196078, 0.847058823529412),
        (0, 0.317647058823529, 0.847058823529412),
        (0, 0.321568627450980, 0.847058823529412),
        (0, 0.325490196078431, 0.847058823529412),
        (0, 0.329411764705882, 0.847058823529412),
        (0, 0.333333333333333, 0.847058823529412),
        (0, 0.337254901960784, 0.847058823529412),
        (0, 0.341176470588235, 0.847058823529412),
        (0, 0.345098039215686, 0.843137254901961),
        (0, 0.349019607843137, 0.843137254901961),
        (0, 0.352941176470588, 0.843137254901961),
        (0, 0.356862745098039, 0.843137254901961),
        (0, 0.360784313725490, 0.843137254901961),
        (0, 0.360784313725490, 0.843137254901961),
        (0, 0.364705882352941, 0.843137254901961),
        (0, 0.364705882352941, 0.843137254901961),
        (0, 0.368627450980392, 0.839215686274510),
        (0, 0.372549019607843, 0.839215686274510),
        (0, 0.376470588235294, 0.839215686274510),
        (0, 0.376470588235294, 0.839215686274510),
        (0, 0.380392156862745, 0.839215686274510),
        (0, 0.384313725490196, 0.835294117647059),
        (0, 0.388235294117647, 0.835294117647059),
        (0, 0.392156862745098, 0.835294117647059),
        (0, 0.396078431372549, 0.835294117647059),
        (0, 0.400000000000000, 0.831372549019608),
        (0, 0.407843137254902, 0.831372549019608),
        (0, 0.411764705882353, 0.831372549019608),
        (0, 0.415686274509804, 0.831372549019608),
        (0, 0.419607843137255, 0.827450980392157),
        (0, 0.423529411764706, 0.827450980392157),
        (0, 0.427450980392157, 0.827450980392157),
        (0, 0.431372549019608, 0.827450980392157),
        (0, 0.435294117647059, 0.827450980392157),
        (0, 0.439215686274510, 0.827450980392157),
        (0, 0.443137254901961, 0.827450980392157),
        (0, 0.447058823529412, 0.827450980392157),
        (0, 0.450980392156863, 0.823529411764706),
        (0, 0.454901960784314, 0.823529411764706),
        (0, 0.458823529411765, 0.823529411764706),
        (0, 0.462745098039216, 0.823529411764706),
        (0, 0.466666666666667, 0.819607843137255),
        (0, 0.466666666666667, 0.819607843137255),
        (0, 0.470588235294118, 0.819607843137255),
        (0, 0.470588235294118, 0.819607843137255),
        (0, 0.470588235294118, 0.819607843137255),
        (0, 0.474509803921569, 0.819607843137255),
        (0, 0.478431372549020, 0.819607843137255),
        (0, 0.482352941176471, 0.819607843137255),
        (0, 0.486274509803922, 0.819607843137255),
        (0, 0.490196078431373, 0.815686274509804),
        (0, 0.494117647058824, 0.815686274509804),
        (0, 0.498039215686275, 0.815686274509804),
        (0, 0.501960784313726, 0.815686274509804),
        (0, 0.505882352941176, 0.811764705882353),
        (0, 0.509803921568627, 0.811764705882353),
        (0, 0.517647058823530, 0.811764705882353),
        (0, 0.521568627450980, 0.811764705882353),
        (0, 0.525490196078431, 0.807843137254902),
        (0, 0.529411764705882, 0.807843137254902),
        (0, 0.533333333333333, 0.807843137254902),
        (0, 0.537254901960784, 0.807843137254902),
        (0, 0.541176470588235, 0.803921568627451),
        (0, 0.545098039215686, 0.803921568627451),
        (0, 0.549019607843137, 0.803921568627451),
        (0, 0.552941176470588, 0.803921568627451),
        (0, 0.556862745098039, 0.803921568627451),
        (0, 0.560784313725490, 0.803921568627451),
        (0, 0.564705882352941, 0.803921568627451),
        (0, 0.568627450980392, 0.803921568627451),
        (0, 0.572549019607843, 0.803921568627451),
        (0, 0.572549019607843, 0.800000000000000),
        (0, 0.572549019607843, 0.800000000000000),
        (0, 0.576470588235294, 0.800000000000000),
        (0, 0.576470588235294, 0.800000000000000),
        (0, 0.580392156862745, 0.800000000000000),
        (0, 0.584313725490196, 0.800000000000000),
        (0, 0.588235294117647, 0.800000000000000),
        (0, 0.592156862745098, 0.800000000000000),
        (0, 0.596078431372549, 0.796078431372549),
        (0, 0.600000000000000, 0.796078431372549),
        (0, 0.603921568627451, 0.796078431372549),
        (0, 0.607843137254902, 0.796078431372549),
        (0, 0.611764705882353, 0.792156862745098),
        (0, 0.615686274509804, 0.792156862745098),
        (0, 0.623529411764706, 0.792156862745098),
        (0, 0.627450980392157, 0.792156862745098),
        (0, 0.631372549019608, 0.788235294117647),
        (0, 0.635294117647059, 0.788235294117647),
        (0, 0.639215686274510, 0.788235294117647),
        (0, 0.643137254901961, 0.788235294117647),
        (0, 0.647058823529412, 0.784313725490196),
        (0, 0.650980392156863, 0.784313725490196),
        (0, 0.654901960784314, 0.784313725490196),
        (0, 0.658823529411765, 0.784313725490196),
        (0, 0.662745098039216, 0.784313725490196),
        (0, 0.662745098039216, 0.784313725490196),
        (0, 0.662745098039216, 0.784313725490196),
        (0, 0.666666666666667, 0.784313725490196),
        (0, 0.666666666666667, 0.784313725490196),
        (0, 0.670588235294118, 0.776470588235294),
        (0.00392156862745098, 0.674509803921569, 0.768627450980392),
        (0.00784313725490196, 0.678431372549020, 0.760784313725490),
        (0.0117647058823529, 0.678431372549020, 0.752941176470588),
        (0.0156862745098039, 0.682352941176471, 0.745098039215686),
        (0.0196078431372549, 0.686274509803922, 0.737254901960784),
        (0.0235294117647059, 0.690196078431373, 0.729411764705882),
        (0.0274509803921569, 0.694117647058824, 0.721568627450980),
        (0.0313725490196078, 0.698039215686275, 0.713725490196078),
        (0.0352941176470588, 0.701960784313725, 0.709803921568628),
        (0.0392156862745098, 0.701960784313725, 0.701960784313725),
        (0.0431372549019608, 0.705882352941177, 0.694117647058824),
        (0.0470588235294118, 0.709803921568628, 0.686274509803922),
        (0.0509803921568627, 0.713725490196078, 0.678431372549020),
        (0.0549019607843137, 0.713725490196078, 0.670588235294118),
        (0.0588235294117647, 0.717647058823529, 0.666666666666667),
        (0.0627450980392157, 0.721568627450980, 0.658823529411765),
        (0.0666666666666667, 0.721568627450980, 0.650980392156863),
        (0.0705882352941177, 0.725490196078431, 0.643137254901961),
        (0.0745098039215686, 0.729411764705882, 0.635294117647059),
        (0.0784313725490196, 0.733333333333333, 0.627450980392157),
        (0.0823529411764706, 0.737254901960784, 0.619607843137255),
        (0.0862745098039216, 0.741176470588235, 0.615686274509804),
        (0.0862745098039216, 0.741176470588235, 0.607843137254902),
        (0.0901960784313726, 0.745098039215686, 0.600000000000000),
        (0.0941176470588235, 0.749019607843137, 0.596078431372549),
        (0.0941176470588235, 0.749019607843137, 0.592156862745098),
        (0.0941176470588235, 0.749019607843137, 0.588235294117647),
        (0.0941176470588235, 0.749019607843137, 0.584313725490196),
        (0.0980392156862745, 0.752941176470588, 0.576470588235294),
        (0.101960784313725, 0.756862745098039, 0.568627450980392),
        (0.105882352941176, 0.760784313725490, 0.560784313725490),
        (0.109803921568627, 0.764705882352941, 0.552941176470588),
        (0.113725490196078, 0.768627450980392, 0.545098039215686),
        (0.117647058823529, 0.772549019607843, 0.537254901960784),
        (0.121568627450980, 0.772549019607843, 0.533333333333333),
        (0.125490196078431, 0.776470588235294, 0.525490196078431),
        (0.129411764705882, 0.780392156862745, 0.517647058823530),
        (0.133333333333333, 0.784313725490196, 0.509803921568627),
        (0.137254901960784, 0.784313725490196, 0.501960784313726),
        (0.141176470588235, 0.788235294117647, 0.494117647058824),
        (0.145098039215686, 0.792156862745098, 0.486274509803922),
        (0.149019607843137, 0.796078431372549, 0.478431372549020),
        (0.152941176470588, 0.800000000000000, 0.474509803921569),
        (0.156862745098039, 0.803921568627451, 0.466666666666667),
        (0.160784313725490, 0.807843137254902, 0.458823529411765),
        (0.164705882352941, 0.807843137254902, 0.450980392156863),
        (0.168627450980392, 0.811764705882353, 0.443137254901961),
        (0.172549019607843, 0.815686274509804, 0.439215686274510),
        (0.172549019607843, 0.815686274509804, 0.431372549019608),
        (0.176470588235294, 0.819607843137255, 0.423529411764706),
        (0.180392156862745, 0.823529411764706, 0.415686274509804),
        (0.184313725490196, 0.827450980392157, 0.407843137254902),
        (0.188235294117647, 0.827450980392157, 0.400000000000000),
        (0.192156862745098, 0.831372549019608, 0.396078431372549),
        (0.192156862745098, 0.831372549019608, 0.392156862745098),
        (0.196078431372549, 0.835294117647059, 0.388235294117647),
        (0.196078431372549, 0.835294117647059, 0.384313725490196),
        (0.200000000000000, 0.839215686274510, 0.376470588235294),
        (0.203921568627451, 0.843137254901961, 0.368627450980392),
        (0.207843137254902, 0.843137254901961, 0.360784313725490),
        (0.211764705882353, 0.847058823529412, 0.356862745098039),
        (0.215686274509804, 0.850980392156863, 0.349019607843137),
        (0.219607843137255, 0.854901960784314, 0.341176470588235),
        (0.223529411764706, 0.854901960784314, 0.333333333333333),
        (0.227450980392157, 0.858823529411765, 0.325490196078431),
        (0.231372549019608, 0.862745098039216, 0.317647058823529),
        (0.235294117647059, 0.866666666666667, 0.309803921568627),
        (0.239215686274510, 0.870588235294118, 0.305882352941177),
        (0.243137254901961, 0.874509803921569, 0.298039215686275),
        (0.247058823529412, 0.878431372549020, 0.290196078431373),
        (0.250980392156863, 0.878431372549020, 0.282352941176471),
        (0.254901960784314, 0.882352941176471, 0.274509803921569),
        (0.258823529411765, 0.886274509803922, 0.266666666666667),
        (0.262745098039216, 0.890196078431373, 0.262745098039216),
        (0.262745098039216, 0.890196078431373, 0.254901960784314),
        (0.266666666666667, 0.894117647058824, 0.247058823529412),
        (0.270588235294118, 0.898039215686275, 0.239215686274510),
        (0.274509803921569, 0.898039215686275, 0.231372549019608),
        (0.278431372549020, 0.901960784313726, 0.223529411764706),
        (0.282352941176471, 0.905882352941177, 0.215686274509804),
        (0.286274509803922, 0.909803921568627, 0.207843137254902),
        (0.290196078431373, 0.913725490196078, 0.200000000000000),
        (0.294117647058824, 0.917647058823529, 0.196078431372549),
        (0.294117647058824, 0.917647058823529, 0.192156862745098),
        (0.294117647058824, 0.917647058823529, 0.188235294117647),
        (0.294117647058824, 0.917647058823529, 0.184313725490196),
        (0.298039215686275, 0.921568627450980, 0.180392156862745),
        (0.301960784313725, 0.925490196078431, 0.172549019607843),
        (0.305882352941177, 0.929411764705882, 0.164705882352941),
        (0.309803921568627, 0.933333333333333, 0.156862745098039),
        (0.313725490196078, 0.937254901960784, 0.149019607843137),
        (0.317647058823529, 0.937254901960784, 0.141176470588235),
        (0.321568627450980, 0.941176470588235, 0.133333333333333),
        (0.325490196078431, 0.945098039215686, 0.125490196078431),
        (0.329411764705882, 0.949019607843137, 0.117647058823529),
        (0.333333333333333, 0.949019607843137, 0.109803921568627),
        (0.337254901960784, 0.952941176470588, 0.105882352941176),
        (0.341176470588235, 0.956862745098039, 0.0980392156862745),
        (0.345098039215686, 0.960784313725490, 0.0901960784313726),
        (0.349019607843137, 0.960784313725490, 0.0862745098039216),
        (0.349019607843137, 0.964705882352941, 0.0784313725490196),
        (0.352941176470588, 0.968627450980392, 0.0705882352941177),
        (0.356862745098039, 0.968627450980392, 0.0627450980392157),
        (0.360784313725490, 0.972549019607843, 0.0549019607843137),
        (0.364705882352941, 0.976470588235294, 0.0470588235294118),
        (0.368627450980392, 0.980392156862745, 0.0392156862745098),
        (0.372549019607843, 0.984313725490196, 0.0313725490196078),
        (0.376470588235294, 0.988235294117647, 0.0235294117647059),
        (0.380392156862745, 0.992156862745098, 0.0156862745098039),
        (0.384313725490196, 0.992156862745098, 0.00784313725490196),
        (0.388235294117647, 0.996078431372549, 0),
        (0.392156862745098, 1, 0),
        (0.396078431372549, 1, 0),
        (0.396078431372549, 1, 0),
        (0.400000000000000, 1, 0),
        (0.403921568627451, 1, 0),
        (0.411764705882353, 1, 0),
        (0.415686274509804, 1, 0),
        (0.419607843137255, 1, 0),
        (0.427450980392157, 1, 0),
        (0.431372549019608, 1, 0),
        (0.439215686274510, 1, 0),
        (0.443137254901961, 1, 0),
        (0.450980392156863, 0.996078431372549, 0),
        (0.454901960784314, 0.996078431372549, 0),
        (0.462745098039216, 0.996078431372549, 0),
        (0.466666666666667, 0.996078431372549, 0),
        (0.470588235294118, 0.996078431372549, 0),
        (0.478431372549020, 0.996078431372549, 0),
        (0.482352941176471, 0.996078431372549, 0),
        (0.490196078431373, 0.996078431372549, 0),
        (0.494117647058824, 0.996078431372549, 0),
        (0.501960784313726, 0.996078431372549, 0),
        (0.505882352941176, 0.996078431372549, 0),
        (0.509803921568627, 0.996078431372549, 0),
        (0.517647058823530, 0.996078431372549, 0),
        (0.525490196078431, 0.996078431372549, 0),
        (0.529411764705882, 0.996078431372549, 0),
        (0.537254901960784, 0.996078431372549, 0),
        (0.545098039215686, 0.996078431372549, 0),
        (0.549019607843137, 0.996078431372549, 0),
        (0.552941176470588, 0.996078431372549, 0),
        (0.552941176470588, 0.996078431372549, 0),
        (0.556862745098039, 0.996078431372549, 0),
        (0.560784313725490, 0.992156862745098, 0),
        (0.564705882352941, 0.992156862745098, 0),
        (0.572549019607843, 0.992156862745098, 0),
        (0.576470588235294, 0.992156862745098, 0),
        (0.584313725490196, 0.992156862745098, 0),
        (0.588235294117647, 0.992156862745098, 0),
        (0.596078431372549, 0.992156862745098, 0),
        (0.600000000000000, 0.992156862745098, 0),
        (0.603921568627451, 0.992156862745098, 0),
        (0.611764705882353, 0.992156862745098, 0),
        (0.615686274509804, 0.992156862745098, 0),
        (0.623529411764706, 0.992156862745098, 0),
        (0.627450980392157, 0.992156862745098, 0),
        (0.635294117647059, 0.992156862745098, 0),
        (0.639215686274510, 0.992156862745098, 0),
        (0.647058823529412, 0.992156862745098, 0),
        (0.650980392156863, 0.992156862745098, 0),
        (0.654901960784314, 0.992156862745098, 0),
        (0.662745098039216, 0.992156862745098, 0),
        (0.666666666666667, 0.992156862745098, 0),
        (0.674509803921569, 0.992156862745098, 0),
        (0.678431372549020, 0.992156862745098, 0),
        (0.682352941176471, 0.992156862745098, 0),
        (0.682352941176471, 0.992156862745098, 0),
        (0.686274509803922, 0.992156862745098, 0),
        (0.690196078431373, 0.988235294117647, 0),
        (0.694117647058824, 0.988235294117647, 0),
        (0.701960784313725, 0.988235294117647, 0),
        (0.705882352941177, 0.988235294117647, 0),
        (0.713725490196078, 0.988235294117647, 0),
        (0.717647058823529, 0.988235294117647, 0),
        (0.725490196078431, 0.988235294117647, 0),
        (0.729411764705882, 0.988235294117647, 0),
        (0.737254901960784, 0.988235294117647, 0),
        (0.741176470588235, 0.988235294117647, 0),
        (0.745098039215686, 0.988235294117647, 0),
        (0.752941176470588, 0.988235294117647, 0),
        (0.756862745098039, 0.988235294117647, 0),
        (0.764705882352941, 0.988235294117647, 0),
        (0.768627450980392, 0.988235294117647, 0),
        (0.776470588235294, 0.988235294117647, 0),
        (0.780392156862745, 0.988235294117647, 0),
        (0.784313725490196, 0.988235294117647, 0),
        (0.792156862745098, 0.988235294117647, 0),
        (0.796078431372549, 0.988235294117647, 0),
        (0.803921568627451, 0.988235294117647, 0),
        (0.807843137254902, 0.984313725490196, 0),
        (0.815686274509804, 0.984313725490196, 0),
        (0.819607843137255, 0.984313725490196, 0),
        (0.827450980392157, 0.984313725490196, 0),
        (0.831372549019608, 0.984313725490196, 0),
        (0.831372549019608, 0.984313725490196, 0),
        (0.835294117647059, 0.984313725490196, 0),
        (0.839215686274510, 0.984313725490196, 0),
        (0.843137254901961, 0.984313725490196, 0),
        (0.850980392156863, 0.984313725490196, 0),
        (0.854901960784314, 0.984313725490196, 0),
        (0.862745098039216, 0.984313725490196, 0),
        (0.870588235294118, 0.984313725490196, 0),
        (0.874509803921569, 0.984313725490196, 0),
        (0.878431372549020, 0.984313725490196, 0),
        (0.886274509803922, 0.984313725490196, 0),
        (0.890196078431373, 0.984313725490196, 0),
        (0.898039215686275, 0.984313725490196, 0),
        (0.901960784313726, 0.984313725490196, 0),
        (0.909803921568627, 0.984313725490196, 0),
        (0.913725490196078, 0.984313725490196, 0),
        (0.921568627450980, 0.980392156862745, 0),
        (0.925490196078431, 0.980392156862745, 0),
        (0.929411764705882, 0.980392156862745, 0),
        (0.937254901960784, 0.980392156862745, 0),
        (0.941176470588235, 0.980392156862745, 0),
        (0.949019607843137, 0.980392156862745, 0),
        (0.952941176470588, 0.980392156862745, 0),
        (0.960784313725490, 0.980392156862745, 0),
        (0.964705882352941, 0.980392156862745, 0),
        (0.972549019607843, 0.980392156862745, 0),
        (0.976470588235294, 0.980392156862745, 0),
        (0.980392156862745, 0.980392156862745, 0),
        (0.988235294117647, 0.980392156862745, 0),
        (0.988235294117647, 0.980392156862745, 0),
        (0.992156862745098, 0.980392156862745, 0),
        (0.996078431372549, 0.980392156862745, 0),
        (1, 0.976470588235294, 0),
        (1, 0.972549019607843, 0),
        (1, 0.964705882352941, 0),
        (1, 0.960784313725490, 0),
        (1, 0.956862745098039, 0),
        (1, 0.949019607843137, 0),
        (1, 0.945098039215686, 0),
        (1, 0.937254901960784, 0),
        (1, 0.933333333333333, 0),
        (1, 0.929411764705882, 0),
        (1, 0.921568627450980, 0),
        (1, 0.917647058823529, 0),
        (1, 0.913725490196078, 0),
        (1, 0.909803921568627, 0),
        (1, 0.901960784313726, 0),
        (1, 0.898039215686275, 0),
        (1, 0.890196078431373, 0),
        (1, 0.886274509803922, 0),
        (1, 0.878431372549020, 0),
        (1, 0.874509803921569, 0),
        (1, 0.870588235294118, 0),
        (1, 0.862745098039216, 0),
        (1, 0.858823529411765, 0),
        (1, 0.850980392156863, 0),
        (1, 0.847058823529412, 0),
        (1, 0.839215686274510, 0),
        (1, 0.839215686274510, 0),
        (1, 0.835294117647059, 0),
        (1, 0.831372549019608, 0),
        (1, 0.831372549019608, 0),
        (1, 0.823529411764706, 0),
        (1, 0.819607843137255, 0),
        (1, 0.811764705882353, 0),
        (1, 0.807843137254902, 0),
        (1, 0.803921568627451, 0),
        (1, 0.796078431372549, 0),
        (1, 0.792156862745098, 0),
        (1, 0.788235294117647, 0),
        (1, 0.784313725490196, 0),
        (1, 0.776470588235294, 0),
        (1, 0.772549019607843, 0),
        (1, 0.764705882352941, 0),
        (1, 0.760784313725490, 0),
        (1, 0.752941176470588, 0),
        (1, 0.749019607843137, 0),
        (1, 0.741176470588235, 0),
        (1, 0.737254901960784, 0),
        (1, 0.733333333333333, 0),
        (1, 0.725490196078431, 0),
        (1, 0.721568627450980, 0),
        (1, 0.713725490196078, 0),
        (1, 0.709803921568628, 0),
        (1, 0.701960784313725, 0),
        (1, 0.698039215686275, 0),
        (1, 0.690196078431373, 0),
        (1, 0.690196078431373, 0),
        (1, 0.690196078431373, 0),
        (1, 0.686274509803922, 0),
        (1, 0.686274509803922, 0),
        (1, 0.678431372549020, 0),
        (1, 0.674509803921569, 0),
        (1, 0.666666666666667, 0),
        (1, 0.662745098039216, 0),
        (1, 0.654901960784314, 0),
        (1, 0.650980392156863, 0),
        (1, 0.647058823529412, 0),
        (1, 0.639215686274510, 0),
        (1, 0.635294117647059, 0),
        (1, 0.627450980392157, 0),
        (1, 0.623529411764706, 0),
        (1, 0.615686274509804, 0),
        (1, 0.611764705882353, 0),
        (1, 0.607843137254902, 0),
        (1, 0.600000000000000, 0),
        (1, 0.596078431372549, 0),
        (1, 0.588235294117647, 0),
        (1, 0.584313725490196, 0),
        (1, 0.580392156862745, 0),
        (1, 0.576470588235294, 0),
        (1, 0.568627450980392, 0),
        (1, 0.564705882352941, 0),
        (1, 0.560784313725490, 0),
        (1, 0.552941176470588, 0),
        (1, 0.549019607843137, 0),
        (1, 0.545098039215686, 0),
        (1, 0.541176470588235, 0),
        (1, 0.537254901960784, 0),
        (1, 0.537254901960784, 0),
        (1, 0.529411764705882, 0),
        (1, 0.525490196078431, 0),
        (1, 0.521568627450980, 0),
        (1, 0.513725490196078, 0),
        (1, 0.509803921568627, 0),
        (1, 0.501960784313726, 0),
        (1, 0.498039215686275, 0),
        (1, 0.490196078431373, 0),
        (1, 0.486274509803922, 0),
        (1, 0.478431372549020, 0),
        (1, 0.474509803921569, 0),
        (1, 0.470588235294118, 0),
        (1, 0.462745098039216, 0),
        (1, 0.458823529411765, 0),
        (1, 0.454901960784314, 0),
        (1, 0.450980392156863, 0),
        (1, 0.443137254901961, 0),
        (1, 0.439215686274510, 0),
        (1, 0.431372549019608, 0),
        (1, 0.427450980392157, 0),
        (1, 0.423529411764706, 0),
        (1, 0.415686274509804, 0),
        (1, 0.411764705882353, 0),
        (1, 0.403921568627451, 0),
        (1, 0.400000000000000, 0),
        (1, 0.396078431372549, 0),
        (1, 0.396078431372549, 0),
        (1, 0.392156862745098, 0),
        (1, 0.392156862745098, 0),
        (1, 0.388235294117647, 0),
        (1, 0.384313725490196, 0),
        (1, 0.384313725490196, 0),
        (1, 0.380392156862745, 0),
        (1, 0.376470588235294, 0),
        (1, 0.372549019607843, 0),
        (1, 0.372549019607843, 0),
        (1, 0.368627450980392, 0),
        (1, 0.364705882352941, 0),
        (1, 0.360784313725490, 0),
        (1, 0.356862745098039, 0),
        (1, 0.352941176470588, 0),
        (1, 0.349019607843137, 0),
        (1, 0.349019607843137, 0),
        (1, 0.345098039215686, 0),
        (1, 0.341176470588235, 0),
        (1, 0.341176470588235, 0),
        (1, 0.337254901960784, 0),
        (1, 0.333333333333333, 0),
        (1, 0.329411764705882, 0),
        (1, 0.325490196078431, 0),
        (1, 0.321568627450980, 0),
        (1, 0.321568627450980, 0),
        (1, 0.321568627450980, 0),
        (1, 0.321568627450980, 0),
        (1, 0.317647058823529, 0),
        (1, 0.313725490196078, 0),
        (1, 0.309803921568627, 0),
        (1, 0.305882352941177, 0),
        (1, 0.301960784313725, 0),
        (1, 0.298039215686275, 0),
        (1, 0.298039215686275, 0),
        (1, 0.294117647058824, 0),
        (1, 0.290196078431373, 0),
        (1, 0.290196078431373, 0),
        (1, 0.286274509803922, 0),
        (1, 0.282352941176471, 0),
        (1, 0.278431372549020, 0),
        (1, 0.274509803921569, 0),
        (1, 0.270588235294118, 0),
        (1, 0.266666666666667, 0),
        (1, 0.262745098039216, 0),
        (1, 0.262745098039216, 0),
        (1, 0.258823529411765, 0),
        (1, 0.254901960784314, 0),
        (1, 0.254901960784314, 0),
        (1, 0.250980392156863, 0),
        (1, 0.247058823529412, 0),
        (1, 0.243137254901961, 0),
        (1, 0.243137254901961, 0),
        (1, 0.239215686274510, 0),
        (1, 0.239215686274510, 0),
        (1, 0.235294117647059, 0),
        (1, 0.235294117647059, 0),
        (1, 0.231372549019608, 0),
        (1, 0.227450980392157, 0),
        (1, 0.223529411764706, 0),
        (1, 0.219607843137255, 0),
        (1, 0.215686274509804, 0),
        (1, 0.215686274509804, 0),
        (1, 0.211764705882353, 0),
        (1, 0.207843137254902, 0),
        (1, 0.203921568627451, 0),
        (1, 0.203921568627451, 0),
        (1, 0.200000000000000, 0),
        (1, 0.196078431372549, 0),
        (1, 0.192156862745098, 0),
        (1, 0.188235294117647, 0),
        (1, 0.188235294117647, 0),
        (1, 0.184313725490196, 0),
        (1, 0.180392156862745, 0),
        (1, 0.176470588235294, 0),
        (1, 0.172549019607843, 0),
        (1, 0.168627450980392, 0),
        (1, 0.168627450980392, 0),
        (1, 0.164705882352941, 0),
        (1, 0.160784313725490, 0),
        (1, 0.160784313725490, 0),
        (1, 0.156862745098039, 0),
        (1, 0.152941176470588, 0),
        (1, 0.152941176470588, 0),
        (1, 0.149019607843137, 0),
        (1, 0.149019607843137, 0),
        (1, 0.145098039215686, 0),
        (1, 0.141176470588235, 0),
        (1, 0.141176470588235, 0),
        (1, 0.137254901960784, 0),
        (1, 0.133333333333333, 0),
        (1, 0.129411764705882, 0),
        (1, 0.125490196078431, 0),
        (1, 0.121568627450980, 0),
        (1, 0.117647058823529, 0),
        (1, 0.117647058823529, 0),
        (1, 0.113725490196078, 0),
        (1, 0.109803921568627, 0),
        (1, 0.109803921568627, 0),
        (1, 0.105882352941176, 0),
        (1, 0.101960784313725, 0),
        (1, 0.0980392156862745, 0),
        (1, 0.0941176470588235, 0),
        (1, 0.0901960784313726, 0),
        (1, 0.0862745098039216, 0),
        (1, 0.0823529411764706, 0),
        (1, 0.0823529411764706, 0),
        (1, 0.0784313725490196, 0),
        (1, 0.0745098039215686, 0),
        (1, 0.0745098039215686, 0),
        (1, 0.0705882352941177, 0)]

    nbins = 600
    labview_cmap = LinearSegmentedColormap.from_list(
        'labview', Labview_RGB, N=nbins
    )
    labview_cmap.set_over(color='white', alpha=1)
    labview_cmap.set_under(color='k', alpha=1)
    labview_cmap.set_bad(color='k', alpha=1)

    return labview_cmap


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


def calipso_colormap_gray_inv():
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
        (0.2745098, 0.2745098, 0.2745098),
        (0.39215686, 0.39215686, 0.39215686),
        (0.50980392, 0.50980392, 0.50980392),
        (0.60784314, 0.60784314, 0.60784314),
        (0.78431373, 0.78431373, 0.78431373)


#        (0.78431373, 0.78431373, 0.78431373),
#        (0.60784314, 0.60784314, 0.60784314),
#        (0.50980392, 0.50980392, 0.50980392),
#        (0.39215686, 0.39215686, 0.39215686),
#        (0.2745098, 0.2745098, 0.2745098)
    ]

    nbins = 1024
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
        - 'calipso'
    Return
    ------
    cmap: matplotlib colormap
    """

    if name == 'chiljet':
        cmap = chiljet_colormap()
    elif name == 'eleni':
        cmap = eleni_colormap()
    elif name == 'calipso':
        cmap = calipso_colormap_gray_inv()
    elif name == 'labview':
        cmap = labivew_colormap()
    else:
        raise RuntimeWarning('Unknown colormap: {0}'.format(name))

    return cmap


def Test():
    print("-------------------Test---------------------")

    import numpy as np
    import matplotlib.pyplot as plt

#    x = np.random.random((40, 40))
#    y = np.random.random((40, 40))
#    X, Y = np.meshgrid(x, y)
#    Z = np.exp(-2*(X**2 + Y**2))

#    plt.contourf(Z, level=255, cmap=calipso_colormap())
#    image_data = np.random.rand(42,42)
#    plt.imshow(image_data, cmap=calipso_colormap_gray_inv())

    # Define the dimensions of the grid
    n = 1024
    x = np.linspace(-2, 2, n)
    y = np.linspace(-2, 2, n)

    # Create a meshgrid
    X, Y = np.meshgrid(x, y)

    # Create a smooth gradient using a function, for example, a Gaussian
    sigma = 1.0
    Z = np.exp(-X**2/(2*sigma**2)) * np.exp(-Y**2/(2*sigma**2))
    plt.imshow(Z, cmap=calipso_colormap_gray_inv())
    plt.colorbar()
    plt.savefig('c:\_data\calipso_colormap_gray_inv.png', dpi=300)
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
    import matplotlib.colors
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

# def eleni_colormap():
#     import matplotlib.colors
#     c = matplotlib.colors.ColorConverter().to_rgb 
#     cmap=eleni_colormap([c('lightskyblue'),c('dodgerblue'), 0.1,
#                           c('dodgerblue'),c('teal'), 0.2,
#                           c('teal'),c('limegreen'), 0.3,
#                           c('limegreen'),c('yellow'), 0.4,
#                           c('yellow'), c('orange'), 0.5,
#                           c('orange'),c('orangered'), 0.6,
#                           c('orangered'), c('red'), 0.7,
#                           c('red'), c('firebrick'), 0.8,
#                           c('firebrick'),c('darkred'), 0.9,
#                           c('darkred'),c('k')])
#     cmap.set_bad(color='white', alpha=1)
#     return cmap

def main():
    Test()


if __name__ == '__main__':
    main()
