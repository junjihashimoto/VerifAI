{ bootstrap ? import <nixpkgs> { },
  nixpkgs ? builtins.fromJSON (builtins.readFile ./nix/nixpkgs.json),

  src ? bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo  = "nixpkgs";
    inherit (nixpkgs) rev sha256;
  },

  pkgs ? import src {
    config = { allowUnsupportedSystem = true; allowUnfree = true; };
#    overlays = [ overlayShared ];
  }
}:

with pkgs;

let
  dotmap = python37.pkgs.buildPythonPackage rec {
    pname = "dotmap";
    version = "1.3.8";

    src = python37.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0b67lf3a0xvvlgyp6qjrpwlka3klwas7hymd8p3dxc1pn2l724w9";
    };

    doCheck = false; # No tests in archive

    meta = {
      homepage = https://github.com/drgrib/dotmap;
      license = with stdenv.lib; licenses.mit;
      description = "Dot access dictionary with dynamic hierarchy creation and ordered iteration";
    };
  };
  singledispatch = python37.pkgs.singledispatch.overrideAttrs (oldAttrs : rec {
    #propagatedBuildInputs = [ lenses ]; #k ++ oldAttrs.propagatedBuildInputs;
    doCheck = false;
  });
  lenses = python37.pkgs.buildPythonPackage rec {
    pname = "lenses";
    version = "0.5.0";

    src = python37.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0jk0kf8rx04zy9wfmf4hprx4y09wvz2mv19kk4n4r27jy9rq2cav";
    };
    propagatedBuildInputs = with python37.pkgs; [
      singledispatch
    ];

    doCheck = false; # No tests in archive

    meta = {
      homepage = https://github.com/ingolemo/python-lenses;
      license = with stdenv.lib; licenses.bsd3;
      description = "A lens library for python";
    };
  };
  discrete-signals = python37.pkgs.buildPythonPackage rec {
    pname = "discrete-signals";
    version = "0.7.3";

    src = python37.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "17srarjqqx717wq1f0i85s2cy8wrl34dfq75v3kizsirfl7wyvqf";
    };
    propagatedBuildInputs = with python37.pkgs; [
      funcy
      sortedcontainers
      attrs
    ];

    doCheck = false; # No tests in archive

    meta = {
      homepage = http://github.com/mvcisback/DiscreteSignals;
      license = with stdenv.lib; licenses.mit;
      description = "A domain specific language for modeling and manipulating discrete time signals.";
    };
  };
  metric-temporal-logic = python37.pkgs.buildPythonPackage rec {
    pname = "metric-temporal-logic";
    version = "0.1.4";

    src = python37.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "1kbq37l2mkspj8d2bp7vicx6xkdpkm0mfjpqq8ah7h3z06r5p544";
    };
    propagatedBuildInputs = with python37.pkgs; [
      funcy
      lenses
      parsimonious
      discrete-signals
    ];
    doCheck = false; # No tests in archive

    meta = {
      homepage = http://github.com/mvcisback/py-metric-temporal-logic;
      license = with stdenv.lib; licenses.bsd3;
      description = "A library for manipulating and evaluating metric temporal logic.";
    };
  };
  Polygon3 = python37.pkgs.buildPythonPackage rec {
    pname = "Polygon3";
    version = "3.0.8";

    src = python37.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0b4yzxdxwv2siy4vy19y4z2hlki41a40z76cf6m380am3fpyqaiq";
    };
    propagatedBuildInputs = with python37.pkgs; [
    ];
    doCheck = false; # No tests in archive

    meta = {
      homepage = http://www.j-raedler.de/projects/polygon;
      license = with stdenv.lib; licenses.bsd3;
      description = "Polygon3 is a Python-3 package that handles polygonal shapes in 2D";
    };
  };
  scenic = python37.pkgs.buildPythonPackage rec {
    pname = "scenic";
    version = "0.7.7";

    src = fetchFromGitHub {
      owner = "BerkeleyLearnVerify";
      repo = "Scenic";
      rev = "ed7c40a324ad0fd176e54209042a2550b6ba0c4e";
      sha256 = "14yix5v20cxa54j7xwasp1hs45g4v5g7z9hqz5rm7g9na7x1zkxq";
    };

    propagatedBuildInputs = with python37.pkgs; [
      numpy
      scipy
      matplotlib
      antlr4-python3-runtime
      opencv4
      pillow
      shapely
      Polygon3
    ];
    checkInputs = with python37.pkgs; [ pytest dill pyproj ];
    preConfigure = ''
      sed -i -e 's/.*opencv-python.*$//g' setup.py
    '';
    doCheck = false;

    meta = with stdenv.lib; {
      description = "A compiler and scene generator for the Scenic scenario description language.";
      homepage = https://github.com/BerkeleyLearnVerify/Scenic;
      license = licenses.bsd3;
#      maintainers = with maintainers; [ nixy ];
    };
  };
  verifai = python37.pkgs.buildPythonPackage rec {
    pname = "verifai";
    version = "0.0.0";

    src = fetchFromGitHub {
      owner = "BerkeleyLearnVerify";
      repo = "VerifAI";
      rev = "d91bc1289d720c055a36fa0e1ad9f68b986ca1a4";
      sha256 = "0r5y59bbqzlm0n7404jld0k6h6pfawzkphmvxay8b93bzw1gyi6p";
    };

    propagatedBuildInputs = with python37.pkgs; [
      numpy
      scipy
      pulp
      dotmap
      metric-temporal-logic
      matplotlib
      easydict
      joblib
      dill
      pyglet
      future
      pandas
      #scikit-learn
      #          scenic @ git+https://github.com/BerkeleyLearnVerify/Scenic.git#egg=scenic',
      scenic
      gym
    ];
    preConfigure = ''
      sed -i -e 's/.*scikit-learn.*$//g' setup.py
    '';
    checkInputs = with python37.pkgs; [ pytest dill pyproj ];
    doCheck = true;
    meta = with stdenv.lib; {
      description = "A compiler and scene generator for the Scenic scenario description language.";
      homepage = https://github.com/BerkeleyLearnVerify/Scenic;
      license = licenses.bsd3;
#      maintainers = with maintainers; [ nixy ];
    };
  };

  myPython = python37.withPackages(ps: with ps; [
    verifai
  ]);
      
in stdenv.mkDerivation {
  name = "python3-shell";
  buildInputs = [ myPython ];

  shellHook = ''
    #export PS1="\[\033[1;32m\][nix-shell:\w]\n$ \[\033[0m\]"
  '';
}
