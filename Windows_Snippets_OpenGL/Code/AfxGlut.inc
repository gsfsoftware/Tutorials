' ########################################################################################
' Microsoft Windows
' File: AfxGlut.inc
' Contents: OpenGL utilities.
' Copyright (c) 2011 José Roca. Freeware. Use at your own risk.
' THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
' EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
' MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
' ########################################################################################

#INCLUDE THIS ONCE
%AFXGLUT_INC = 1

#INCLUDE ONCE "glu.inc"

' ========================================================================================
' Renders a teapot.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutTeapot (BYVAL grid AS LONG, BYVAL dbScale AS DOUBLE, BYVAL dwType AS DWORD)

   STATIC bArraysInitialized AS LONG

   IF bArraysInitialized = 0 THEN

      DIM patchdata(9, 15) AS STATIC LONG

      patchdata(0, 0) = 102 : patchdata(0, 1) = 103 : patchdata(0, 2) = 104 : patchdata(0, 3) = 105
      patchdata(0, 4) =   4 : patchdata(0, 5) =   5 : patchdata(0, 6) =   6 : patchdata(0, 7) =   7
      patchdata(0, 9) =   8 : patchdata(0, 9) =   9 : patchdata(0,10) =  10 : patchdata(0,11) =  11
      patchdata(0,12) =  12 : patchdata(0,13) =  13 : patchdata(0,14) =  14 : patchdata(0,15) =  15

      patchdata(1, 0) =  12 : patchdata(1, 1) =  13 : patchdata(1, 2) =  14 : patchdata(1, 3) =  15
      patchdata(1, 4) =  16 : patchdata(1, 5) =  17 : patchdata(1, 6) =  17 : patchdata(1, 7) =  19
      patchdata(1, 8) =  20 : patchdata(1, 9) =  21 : patchdata(1,10) =  22 : patchdata(1,11) =  23
      patchdata(1,12) =  24 : patchdata(1,13) =  25 : patchdata(1,14) =  26 : patchdata(1,15) =  27

      patchdata(2, 0) =  24 : patchdata(2, 1) =  25 : patchdata(2, 2) =  26 : patchdata(2, 3) =  27
      patchdata(2, 4) =  29 : patchdata(2, 5) =  30 : patchdata(2, 6) =  31 : patchdata(2, 7) =  32
      patchdata(2, 8) =  33 : patchdata(2, 9) =  34 : patchdata(2,10) =  35 : patchdata(2,11) =  36
      patchdata(2,12) =  37 : patchdata(2,13) =  38 : patchdata(2,14) =  39 : patchdata(2,15) =  40

      patchdata(3, 0) =  96 : patchdata(3, 1) =  96 : patchdata(3, 2) =  96 : patchdata(3, 3) =  96
      patchdata(3, 4) =  97 : patchdata(3, 5) =  98 : patchdata(3, 6) =  99 : patchdata(3, 7) = 100
      patchdata(3, 8) = 101 : patchdata(3, 9) = 101 : patchdata(3,10) = 101 : patchdata(3,11) = 101
      patchdata(3,12) =   0 : patchdata(3,13) =   1 : patchdata(3,14) =   2 : patchdata(3,15) =   3

      patchdata(4, 0) =   0 : patchdata(4, 1) =   1 : patchdata(4, 2) =   2 : patchdata(4, 3) =   3
      patchdata(4, 4) = 106 : patchdata(4, 5) = 107 : patchdata(4, 6) = 108 : patchdata(4, 7) = 109
      patchdata(4, 8) = 101 : patchdata(4, 9) = 101 : patchdata(4,10) = 101 : patchdata(4,11) = 101
      patchdata(4,12) = 114 : patchdata(4,13) = 115 : patchdata(4,14) = 116 : patchdata(4,15) = 117

      patchdata(5, 0) = 118 : patchdata(5, 1) = 118 : patchdata(5, 2) = 118 : patchdata(5, 3) = 118
      patchdata(5, 4) = 124 : patchdata(5, 5) = 122 : patchdata(5, 6) = 119 : patchdata(5, 7) = 121
      patchdata(5, 8) = 123 : patchdata(5, 9) = 126 : patchdata(5,10) = 125 : patchdata(5,11) = 120
      patchdata(5,12) =  40 : patchdata(5,13) =  39 : patchdata(5,14) =  38 : patchdata(5,15) =  37

      patchdata(6, 0) =  41 : patchdata(6, 1) =  42 : patchdata(6, 2) =  43 : patchdata(6, 3) =  44
      patchdata(6, 4) =  45 : patchdata(6, 5) =  46 : patchdata(6, 6) =  47 : patchdata(6, 7) =  48
      patchdata(6, 8) =  49 : patchdata(6, 9) =  50 : patchdata(6,10) =  51 : patchdata(6,11) =  52
      patchdata(6,12) =  53 : patchdata(6,13) =  54 : patchdata(6,14) =  55 : patchdata(6,15) =  56

      patchdata(7, 0) =  53 : patchdata(7, 1) =  54 : patchdata(7, 2) =  55 : patchdata(7, 3) =  56
      patchdata(7, 4) =  57 : patchdata(7, 5) =  58 : patchdata(7, 6) =  59 : patchdata(7, 7) =  60
      patchdata(7, 8) =  61 : patchdata(7, 9) =  62 : patchdata(7,10) =  63 : patchdata(7,11) =  64
      patchdata(7,12) =  28 : patchdata(7,13) =  65 : patchdata(7,14) =  66 : patchdata(7,15) =  67

      patchdata(8, 0) =  68 : patchdata(8, 1) =  69 : patchdata(8, 2) =  70 : patchdata(8, 3) =  71
      patchdata(8, 4) =  72 : patchdata(8, 5) =  73 : patchdata(8, 6) =  74 : patchdata(8, 7) =  75
      patchdata(8, 8) =  76 : patchdata(8, 9) =  77 : patchdata(8,10) =  78 : patchdata(8,11) =  79
      patchdata(8,12) =  80 : patchdata(8,13) =  81 : patchdata(8,14) =  82 : patchdata(8,15) =  83

      patchdata(9, 0) =  80 : patchdata(9, 1) =  81 : patchdata(9, 2) =  82 : patchdata(9, 3) =  83
      patchdata(9, 4) =  84 : patchdata(9, 5) =  84 : patchdata(9, 6) =  86 : patchdata(9, 7) =  87
      patchdata(9, 8) =  88 : patchdata(9, 9) =  89 : patchdata(9,10) =  90 : patchdata(9,11) =  91
      patchdata(9,12) =  92 : patchdata(9,13) =  93 : patchdata(9,14) =  94 : patchdata(9,15) =  95

      DIM cpdata(126, 3) AS STATIC DOUBLE

      cpdata(0, 0) = 0.2#     : cpdata(0, 1) = 0#        : cpdata(0, 2) = 2.7#
      cpdata(1, 0) = 0.2#     : cpdata(1, 1) = -0.112#   : cpdata(1, 2) = 2.7#
      cpdata(2, 0) = 0.112#   : cpdata(2, 1) = -0.2#     : cpdata(2, 2) = 2.7#
      cpdata(3, 0) = 0#       : cpdata(3, 1) = -0.2#     : cpdata(3, 2) = 2.7#
      cpdata(4, 0) = 1.3375#  : cpdata(4, 1) = 0#        : cpdata(4, 2) = 2.53125#
      cpdata(5, 0) = 1.3375#  : cpdata(5, 1) = -0.749#   : cpdata(5, 2) = 2.53125#
      cpdata(6, 0) = 0.749#   : cpdata(6, 1) = -1.3375#  : cpdata(6, 2) = 2.53125#
      cpdata(7, 0) = 0#       : cpdata(7, 1) = -1.3375#  : cpdata(7, 2) = 2.53125#
      cpdata(8, 0) = 1.4375#  : cpdata(8, 1) = 0#        : cpdata(8, 2) = 2.53125#
      cpdata(9, 0) = 1.4375#  : cpdata(9, 1) = -0.805#   : cpdata(9, 2) = 2.53125#
      cpdata(10, 0) = 0.805#  : cpdata(10, 1) = -1.4375# : cpdata(10, 2) = 2.53125#
      cpdata(11, 0) = 0#      : cpdata(11, 1) = -1.4375# : cpdata(11, 2) = 2.53125#
      cpdata(12, 0) = 1.5#    : cpdata(12, 1) = 0#       : cpdata(12, 2) = 2.4#
      cpdata(13, 0) = 1.5#    : cpdata(13, 1) = -0.84#   : cpdata(13, 2) = 2.4#
      cpdata(14, 0) = 0.84#   : cpdata(14, 1) = -1.5#    : cpdata(14, 2) = 2.4#
      cpdata(15, 0) = 0#      : cpdata(15, 1) = -1.5#    : cpdata(15, 2) = 2.4#
      cpdata(16, 0) = 1.75#   : cpdata(16, 1) = 0#       : cpdata(16, 2) = 1.875#
      cpdata(17, 0) = 1.75#   : cpdata(17, 1) = -0.98#   : cpdata(17, 2) = 1.875#
      cpdata(18, 0) = 0.98#   : cpdata(18, 1) = -1.75#   : cpdata(18, 2) = 1.875#
      cpdata(19, 0) = 0#      : cpdata(19, 1) = -1.75#   : cpdata(19, 2) = 1.875#
      cpdata(20, 0) = 2#      : cpdata(20, 1) = 0#       : cpdata(20, 2) = 1.35#
      cpdata(21, 0) = 2#      : cpdata(21, 1) = -1.12#   : cpdata(21, 2) = 1.35#
      cpdata(22, 0) = 1.12#   : cpdata(22, 1) = -2#      : cpdata(22, 2) = 1.35#
      cpdata(23, 0) = 0#      : cpdata(23, 1) = -2#      : cpdata(23, 2) = 1.35#
      cpdata(24, 0) = 2#      : cpdata(24, 1) = 0#       : cpdata(24, 2) = 0.9#
      cpdata(25, 0) = 2#      : cpdata(25, 1) = -1.12#   : cpdata(25, 2) = 0.9#
      cpdata(26, 0) = 1.12#   : cpdata(26, 1) = -2#      : cpdata(26, 2) = 0.9#
      cpdata(27, 0) = 0#      : cpdata(27, 1) = -2#      : cpdata(27, 2) = 0.9#
      cpdata(28, 0) = -2#     : cpdata(28, 1) = 0#       : cpdata(28, 2) = 0.9#
      cpdata(29, 0) = 2#      : cpdata(29, 1) = 0#       : cpdata(29, 2) = 0.45#
      cpdata(30, 0) = 2#      : cpdata(30, 1) = -1.12#   : cpdata(30, 2) = 0.45#
      cpdata(31, 0) = 1.12#   : cpdata(31, 1) = -2#      : cpdata(31, 2) = 0.45#
      cpdata(32, 0) = 0#      : cpdata(32, 1) = -2#      : cpdata(32, 2) = 0.45#
      cpdata(33, 0) = 1.5#    : cpdata(33, 1) = 0#       : cpdata(33, 2) = 0.225#
      cpdata(34, 0) = 1.5#    : cpdata(34, 1) = -0.84#   : cpdata(34, 2) = 0.225#
      cpdata(35, 0) = 0.84#   : cpdata(35, 1) = -1.5#    : cpdata(35, 2) = 0.225#
      cpdata(36, 0) = 0#      : cpdata(36, 1) = -1.5#    : cpdata(36, 2) = 0.225#
      cpdata(37, 0) = 1.5#    : cpdata(37, 1) = 0#       : cpdata(37, 2) = 0.15#
      cpdata(38, 0) = 1.5#    : cpdata(38, 1) = -0.84#   : cpdata(38, 2) = 0.15#
      cpdata(39, 0) = 0.84#   : cpdata(39, 1) = -1.5#    : cpdata(39, 2) = 0.15#
      cpdata(40, 0) = 0#      : cpdata(40, 1) = -1.5#    : cpdata(40, 2) = 0.15#
      cpdata(41, 0) = -1.6#   : cpdata(41, 1) = 0#       : cpdata(41, 2) = 2.025#
      cpdata(42, 0) = -1.6#   : cpdata(42, 1) = -0.3#    : cpdata(42, 2) = 2.025#
      cpdata(43, 0) = -1.5#   : cpdata(43, 1) = -0.3#    : cpdata(43, 2) = 2.25#
      cpdata(44, 0) = -1.5#   : cpdata(44, 1) = 0#       : cpdata(44, 2) = 2.25#
      cpdata(45, 0) = -2.3#   : cpdata(45, 1) = 0#       : cpdata(45, 2) = 2.025#
      cpdata(46, 0) = -2.3#   : cpdata(46, 1) = -0.3#    : cpdata(46, 2) = 2.025#
      cpdata(47, 0) = -2.5#   : cpdata(47, 1) = -0.3#    : cpdata(47, 2) = 2.25#
      cpdata(48, 0) = -2.5#   : cpdata(48, 1) = 0#       : cpdata(48, 2) = 2.25#
      cpdata(49, 0) = -2.7#   : cpdata(49, 1) = 0#       : cpdata(49, 2) = 2.025#
      cpdata(50, 0) = -2.7#   : cpdata(50, 1) = -0.3#    : cpdata(50, 2) = 2.025#
      cpdata(51, 0) = -3#     : cpdata(51, 1) = -0.3#    : cpdata(51, 2) = 2.25#
      cpdata(52, 0) = -3#     : cpdata(52, 1) = 0#       : cpdata(52, 2) = 2.25#
      cpdata(53, 0) = -2.7#   : cpdata(53, 1) = 0#       : cpdata(53, 2) = 1.8#
      cpdata(54, 0) = -2.7#   : cpdata(54, 1) = -0.3#    : cpdata(54, 2) = 1.8#
      cpdata(55, 0) = -3#     : cpdata(55, 1) = -0.3#    : cpdata(55, 2) = 1.8#
      cpdata(56, 0) = -3#     : cpdata(56, 1) = 0#       : cpdata(56, 2) = 1.8#
      cpdata(57, 0) = -2.7#   : cpdata(57, 1) = 0#       : cpdata(57, 2) = 1.575#
      cpdata(58, 0) = -2.7#   : cpdata(58, 1) = -0.3#    : cpdata(58, 2) = 1.575#
      cpdata(59, 0) = -3#     : cpdata(59, 1) = -0.3#    : cpdata(59, 2) = 1.35#
      cpdata(60, 0) = -3#     : cpdata(60, 1) = 0#       : cpdata(60, 2) = 1.35#
      cpdata(61, 0) = -2.5#   : cpdata(61, 1) = 0#       : cpdata(61, 2) = 1.125#
      cpdata(62, 0) = -2.5#   : cpdata(62, 1) = -0.3#    : cpdata(62, 2) = 1.125#
      cpdata(63, 0) = -2.65#  : cpdata(63, 1) = -0.3#    : cpdata(63, 2) = 0.9375#
      cpdata(64, 0) = -2.65#  : cpdata(64, 1) = 0#       : cpdata(64, 2) = 0.9375#
      cpdata(65, 0) = -2#     : cpdata(65, 1) = -0.3#    : cpdata(65, 2) = 0.9#
      cpdata(66, 0) = -1.9#   : cpdata(66, 1) = -0.3#    : cpdata(66, 2) = 0.6#
      cpdata(67, 0) = -1.9#   : cpdata(67, 1) = 0#       : cpdata(67, 2) = 0.6#
      cpdata(68, 0) = 1.7#    : cpdata(68, 1) = 0#       : cpdata(68, 2) = 1.425#
      cpdata(69, 0) = 1.7#    : cpdata(69, 1) = -0.66#   : cpdata(69, 2) = 1.425#
      cpdata(70, 0) = 1.7#    : cpdata(70, 1) = -0.66#   : cpdata(70, 2) = 0.6#
      cpdata(71, 0) = 1.7#    : cpdata(71, 1) = 0#       : cpdata(71, 2) = 0.6#
      cpdata(72, 0) = 2.6#    : cpdata(72, 1) = 0#       : cpdata(72, 2) = 1.425#
      cpdata(73, 0) = 2.6#    : cpdata(73, 1) = -0.66#   : cpdata(73, 2) = 1.425#
      cpdata(74, 0) = 3.1#    : cpdata(74, 1) = -0.66#   : cpdata(74, 2) = 0.825#
      cpdata(75, 0) = 3.1#    : cpdata(75, 1) = 0#       : cpdata(75, 2) = 0.825#
      cpdata(76, 0) = 2.3#    : cpdata(76, 1) = 0#       : cpdata(76, 2) = 2.1#
      cpdata(77, 0) = 2.3#    : cpdata(77, 1) = -0.25#   : cpdata(77, 2) = 2.1#
      cpdata(78, 0) = 2.4#    : cpdata(78, 1) = -0.25#   : cpdata(78, 2) = 2.025#
      cpdata(79, 0) = 2.4#    : cpdata(79, 1) = 0#       : cpdata(79, 2) = 2.025#
      cpdata(80, 0) = 2.7#    : cpdata(80, 1) = 0#       : cpdata(80, 2) = 2.4#
      cpdata(81, 0) = 2.7#    : cpdata(81, 1) = -0.25#   : cpdata(81, 2) = 2.4#
      cpdata(82, 0) = 3.3#    : cpdata(82, 1) = -0.25#   : cpdata(82, 2) = 2.4#
      cpdata(83, 0) = 3.3#    : cpdata(83, 1) = 0#       : cpdata(83, 2) = 2.4#
      cpdata(84, 0) = 2.8#    : cpdata(84, 1) = 0#       : cpdata(84, 2) = 2.475#
      cpdata(85, 0) = 2.8#    : cpdata(85, 1) = -0.25#   : cpdata(85, 2) = 2.475#
      cpdata(86, 0) = 3.525#  : cpdata(86, 1) = -0.25#   : cpdata(86, 2) = 2.49375#
      cpdata(87, 0) = 3.525#  : cpdata(87, 1) = 0#       : cpdata(87, 2) = 2.49375#
      cpdata(88, 0) = 2.9#    : cpdata(88, 1) = -0.25#   : cpdata(88, 2) = 2.475#
      cpdata(89, 0) = 2.9#    : cpdata(89, 1) = -0.15#   : cpdata(89, 2) = 2.475#
      cpdata(90, 0) = 3.45#   : cpdata(90, 1) = -0.15#   : cpdata(90, 2) = 2.5125#
      cpdata(91, 0) = 3.45#   : cpdata(91, 1) = 0#       : cpdata(91, 2) = 2.5125#
      cpdata(92, 0) = 2.8#    : cpdata(92, 1) = 0#       : cpdata(92, 2) = 2.4#
      cpdata(93, 0) = 2.8#    : cpdata(93, 1) = -0.15#   : cpdata(93, 2) = 2.4#
      cpdata(94, 0) = 3.2#    : cpdata(94, 1) = -0.15#   : cpdata(94, 2) = 2.4#
      cpdata(95, 0) = 3.2#    : cpdata(95, 1) = 0#       : cpdata(95, 2) = 2.4#
      cpdata(96, 0) = 0#      : cpdata(96, 1) = 0#       : cpdata(96, 2) = 3.15#
      cpdata(97, 0) = 0.8#    : cpdata(97, 1) = 0#       : cpdata(97, 2) = 3.15#
      cpdata(98, 0) = 0.8#    : cpdata(98, 1) = -0.45#   : cpdata(98, 2) = 3.15#
      cpdata(99, 0) = 0.45#   : cpdata(99, 1) = -0.8#    : cpdata(99, 2) = 3.15#
      cpdata(100, 0) = 0#     : cpdata(100, 1) = -0.8#   : cpdata(100, 2) = 3.15#
      cpdata(101, 0) = 0#     : cpdata(101, 1) = 0#      : cpdata(101, 2) = 2.85#
      cpdata(102, 0) = 1.4#   : cpdata(102, 1) = 0#      : cpdata(102, 2) = 2.4#
      cpdata(103, 0) = 1.4#   : cpdata(103, 1) = -0.784# : cpdata(103, 2) = 2.4#
      cpdata(104, 0) = 0.784# : cpdata(104, 1) = -1.4#   : cpdata(104, 2) = 2.4#
      cpdata(105, 0) = 0#     : cpdata(105, 1) = -1.4#   : cpdata(105, 2) = 2.4#
      cpdata(106, 0) = 0.4#   : cpdata(106, 1) = 0#      : cpdata(106, 2) = 2.55#
      cpdata(107, 0) = 0.4#   : cpdata(107, 1) = -0.224# : cpdata(107, 2) = 2.55#
      cpdata(108, 0) = 0.224# : cpdata(108, 1) = -0.4#   : cpdata(108, 2) = 2.55#
      cpdata(109, 0) = 0#     : cpdata(109, 1) = -0.4#   : cpdata(109, 2) = 2.55#
      cpdata(110, 0) = 1.3#   : cpdata(110, 1) = 0#      : cpdata(110, 2) = 2.55#
      cpdata(111, 0) = 1.3#   : cpdata(111, 1) = -0.728# : cpdata(111, 2) = 2.55#
      cpdata(112, 0) = 0.728# : cpdata(112, 1) = -1.3#   : cpdata(112, 2) = 2.55#
      cpdata(113, 0) = 0#     : cpdata(113, 1) = -1.3#   : cpdata(113, 2) = 2.55#
      cpdata(114, 0) = 1.3#   : cpdata(114, 1) = 0#      : cpdata(114, 2) = 2.4#
      cpdata(115, 0) = 1.3#   : cpdata(115, 1) = -0.728# : cpdata(115, 2) = 2.4#
      cpdata(116, 0) = 0.728# : cpdata(116, 1) = -1.3#   : cpdata(116, 2) = 2.4#
      cpdata(117, 0) = 0#     : cpdata(117, 1) = -1.3#   : cpdata(117, 2) = 2.4#
      cpdata(118, 0) = 0#     : cpdata(118, 1) = 0#      : cpdata(118, 2) = 0#
      cpdata(119, 0) = 1.425# : cpdata(119, 1) = -0.798# : cpdata(119, 2) = 0#
      cpdata(120, 0) = 1.5#   : cpdata(120, 1) = 0#      : cpdata(120, 2) = 0.075#
      cpdata(121, 0) = 1.425# : cpdata(121, 1) = 0#      : cpdata(121, 2) = 0#
      cpdata(122, 0) = 0.798# : cpdata(122, 1) = -1.425# : cpdata(122, 2) = 0#
      cpdata(123, 0) = 0#     : cpdata(123, 1) = -1.5#   : cpdata(123, 2) = 0.075#
      cpdata(124, 0) = 0#     : cpdata(124, 1) = -1.425# : cpdata(124, 2) = 0#
      cpdata(125, 0) = 1.5#   : cpdata(125, 1) = -0.84#  : cpdata(125, 2) = 0.075#
      cpdata(126, 0) = 0.84#  : cpdata(126, 1) = -1.5#   : cpdata(126, 2) = 0.075#

      DIM tex(1, 1, 1) AS STATIC DOUBLE

      tex(0,0,0) = 0.0#
      tex(1,0,0) = 0.0#
      tex(0,1,0) = 1.0#
      tex(1,1,0) = 0.0#
      tex(0,0,1) = 0.0#
      tex(1,0,1) = 1.0#
      tex(0,1,1) = 1.0#
      tex(1,1,1) = 1.0#

   END IF

   bArraysInitialized = 1

   DIM p(2, 3, 3) AS DOUBLE
   DIM q(2, 3, 3) AS DOUBLE
   DIM r(2, 3, 3) AS DOUBLE
   DIM s(2, 3, 3) AS DOUBLE

   LOCAL i, j, k, l AS LONG

   glPushAttrib(%GL_ENABLE_BIT OR %GL_EVAL_BIT)
   glEnable(%GL_AUTO_NORMAL)
   glEnable(%GL_NORMALIZE)
   glEnable(%GL_MAP2_VERTEX_3)
   glEnable(%GL_MAP2_TEXTURE_COORD_2)

   glPushMatrix
   glRotated(270.0, 1.0, 0.0, 0.0)
   glScaled(0.5 * dbScale, 0.5 * dbScale, 0.5 * dbScale)
   glTranslated(0.0, 0.0, -1.5)

   FOR i = 0 TO 9
      FOR j = 0 TO 3
         FOR k = 0 TO 3
            FOR l = 0 TO 2
               p(l,k,j) = cpdata(patchdata(i,j * 4 + k), l)
               q(l,k,j) = cpdata(patchdata(i,j * 4 + (3 - k)),l)
               IF l = 1 THEN q(l,k,j) *= -1.0
               IF i < 6 THEN r(l,k,j) = cpdata(patchdata(i,j * 4 + (3 - k)), l)
               IF l = 0 THEN r(l,k,j) *= -1.0
               s(l,k,j) = cpdata(patchdata(i,j * 4 + k),l)
               IF l = 0 THEN s(l,k,j) *= -1.0
               IF l = 1 THEN s(l,k,j) *= -1.0
            NEXT
         NEXT
      NEXT
      glMap2d(%GL_MAP2_TEXTURE_COORD_2, 0.0, 1.0, 2, 2, 0.0, 1.0, 4, 2, tex(0,0,0))
      glMap2d(%GL_MAP2_VERTEX_3, 0.0, 1.0, 3, 4, 0.0, 1.0, 12, 4, p(0,0,0))
      glMapGrid2d(grid, 0.0, 1.0, grid, 0.0, 1.0)
      glEvalMesh2(dwType, 0, grid, 0, grid)
      glMap2d(%GL_MAP2_VERTEX_3, 0.0, 1.0, 3, 4, 0.0, 1.0, 12, 4, q(0,0,0))
      glEvalMesh2(dwType, 0, grid, 0, grid)
      IF i < 6 THEN
         glMap2d(%GL_MAP2_VERTEX_3, 0.0, 1.0, 3, 4, 0.0, 1.0, 12, 4, r(0,0,0))
         glEvalMesh2(dwType, 0, grid, 0, grid)
         glMap2d(%GL_MAP2_VERTEX_3, 0.0, 1.0, 3, 4, 0.0, 1.0, 12, 4, s(0,0,0))
         glEvalMesh2(dwType, 0, grid, 0, grid)
      END IF
   NEXT

   glPopMatrix
   glPopAttrib

END SUB
' ========================================================================================

' ========================================================================================
' Renders a beautiful wired teapot...
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireTeapot (BYVAL dbSize AS DOUBLE)
   ' /* We will use the general teapot rendering code */
   AfxGlutTeapot(10, dbSize, %GL_LINE)
END SUB
' ========================================================================================

' ========================================================================================
' Renders a beautiful filled teapot...
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidTeapot (BYVAL dbSize AS DOUBLE)
   ' /* We will use the general teapot rendering code */
   AfxGlutTeapot(7, dbSize, %GL_FILL)
END SUB
' ========================================================================================

' ========================================================================================
' Draws a wireframed cube.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireCube (BYVAL dSize AS DOUBLE)

   LOCAL dblSize AS DOUBLE
   dblSize = dSize * 0.5

   glBegin(%GL_LINE_LOOP)
      glNormal3d(1.0, 0.0, 0.0)
      glVertex3d(dblSize, -dblSize, dblSize)
      glVertex3d(dblSize, -dblSize, -dblSize)
      glVertex3d(dblSize, dblSize, -dblSize)
      glVertex3d(dblSize, dblSize, dblSize)
   glEnd
   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.0, 1.0, 0.0)
      glVertex3d(dblSize, dblSize, dblSize)
      glVertex3d(dblSize, dblSize, -dblSize)
      glVertex3d(-dblSize, dblSize, -dblSize)
      glVertex3d(-dblSize, dblSize, dblSize)
   glEnd
   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.0, 0.0, 1.0)
      glVertex3d(dblSize, dblSize, dblSize)
      glVertex3d(-dblSize, dblSize, dblSize)
      glVertex3d(-dblSize, -dblSize, dblSize)
      glVertex3d(dblSize, -dblSize, dblSize)
   glEnd
   glBegin(%GL_LINE_LOOP)
      glNormal3d(-1.0, 0.0, 0.0)
      glVertex3d(-dblSize, -dblSize, dblSize)
      glVertex3d(-dblSize, dblSize, dblSize)
      glVertex3d(-dblSize, dblSize, -dblSize)
      glVertex3d(-dblSize, -dblSize, -dblSize)
   glEnd
   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.0,-1.0, 0.0)
      glVertex3d(-dblSize, -dblSize, dblSize)
      glVertex3d(-dblSize, -dblSize, -dblSize)
      glVertex3d(dblSize, -dblSize, -dblSize)
      glVertex3d(dblSize, -dblSize, dblSize)
   glEnd
   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.0, 0.0,-1.0)
      glVertex3d(-dblSize, -dblSize, -dblSize)
      glVertex3d(-dblSize, dblSize, -dblSize)
      glVertex3d(dblSize, dblSize, -dblSize)
      glVertex3d(dblSize, -dblSize, -dblSize)
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
' Draws a solid cube.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidCube (BYVAL dSize AS DOUBLE)

   LOCAL dblSize AS DOUBLE
   dblSize = dSize * 0.5

   glBegin(%GL_QUADS)
      glNormal3d(1.0, 0.0, 0.0)
      glVertex3d(dblSize, -dblSize, dblSize)
      glVertex3d(dblSize, -dblSize, -dblSize)
      glVertex3d(dblSize, dblSize, -dblSize)
      glVertex3d(dblSize, dblSize, dblSize)
      glNormal3d(0.0, 1.0, 0.0)
      glVertex3d(dblSize, dblSize, dblSize)
      glVertex3d(dblSize, dblSize, -dblSize)
      glVertex3d(-dblSize, dblSize, -dblSize)
      glVertex3d(-dblSize, dblSize, dblSize)
      glNormal3d(0.0, 0.0, 1.0)
      glVertex3d(dblSize, dblSize, dblSize)
      glVertex3d(-dblSize, dblSize, dblSize)
      glVertex3d(-dblSize, -dblSize, dblSize)
      glVertex3d(dblSize, -dblSize, dblSize)
      glNormal3d(-1.0, 0.0, 0.0)
      glVertex3d(-dblSize, -dblSize, dblSize)
      glVertex3d(-dblSize, dblSize, dblSize)
      glVertex3d(-dblSize, dblSize, -dblSize)
      glVertex3d(-dblSize, -dblSize, -dblSize)
      glNormal3d(0.0,-1.0, 0.0)
      glVertex3d(-dblSize, -dblSize, dblSize)
      glVertex3d(-dblSize, -dblSize, -dblSize)
      glVertex3d(dblSize, -dblSize, -dblSize)
      glVertex3d(dblSize, -dblSize, dblSize)
      glNormal3d(0.0, 0.0,-1.0)
      glVertex3d(-dblSize, -dblSize, -dblSize)
      glVertex3d(-dblSize, dblSize, -dblSize)
      glVertex3d(dblSize, dblSize, -dblSize)
      glVertex3d(dblSize, -dblSize, -dblSize)
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
' Renders a wireframe octahedron centered at the modeling coordinates origin with a radius of 1.0.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireOctahedron

   LOCAL RADIUS AS DOUBLE
   RADIUS = 1.0#

   glBegin(%GL_LINE_LOOP)
      glNormal3d( 0.577350269189#, 0.577350269189#, 0.577350269189#) : glVertex3d( RADIUS, 0.0, 0.0) : glVertex3d( 0.0, RADIUS, 0.0) : glVertex3d(0.0, 0.0, RADIUS)
      glNormal3d( 0.577350269189#, 0.577350269189#,-0.577350269189#) : glVertex3d( RADIUS, 0.0, 0.0) : glVertex3d( 0.0, 0.0,-RADIUS) : glVertex3d(0.0, RADIUS, 0.0)
      glNormal3d( 0.577350269189#,-0.577350269189#, 0.577350269189#) : glVertex3d( RADIUS, 0.0, 0.0) : glVertex3d( 0.0, 0.0, RADIUS) : glVertex3d(0.0,-RADIUS, 0.0)
      glNormal3d( 0.577350269189#,-0.577350269189#,-0.577350269189#) : glVertex3d( RADIUS, 0.0, 0.0) : glVertex3d( 0.0,-RADIUS, 0.0) : glVertex3d(0.0, 0.0,-RADIUS)
      glNormal3d(-0.577350269189#, 0.577350269189#, 0.577350269189#) : glVertex3d(-RADIUS, 0.0, 0.0) : glVertex3d( 0.0, 0.0, RADIUS) : glVertex3d(0.0, RADIUS, 0.0)
      glNormal3d(-0.577350269189#, 0.577350269189#,-0.577350269189#) : glVertex3d(-RADIUS, 0.0, 0.0) : glVertex3d( 0.0, RADIUS, 0.0) : glVertex3d(0.0, 0.0,-RADIUS)
      glNormal3d(-0.577350269189#,-0.577350269189#, 0.577350269189#) : glVertex3d(-RADIUS, 0.0, 0.0) : glVertex3d( 0.0,-RADIUS, 0.0) : glVertex3d(0.0, 0.0, RADIUS)
      glNormal3d(-0.577350269189#,-0.577350269189#,-0.577350269189#) : glVertex3d(-RADIUS, 0.0, 0.0) : glVertex3d( 0.0, 0.0,-RADIUS) : glVertex3d(0.0,-RADIUS, 0.0)
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
' Renders a solid octahedron centered at the modeling coordinates origin with a radius of 1.0.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidOctahedron

   LOCAL RADIUS AS DOUBLE
   RADIUS = 1.0#

   glBegin(%GL_TRIANGLES)
      glNormal3d( 0.577350269189#, 0.577350269189#, 0.577350269189#) : glVertex3d( RADIUS, 0.0, 0.0) : glVertex3d( 0.0, RADIUS, 0.0) : glVertex3d(0.0, 0.0, RADIUS)
      glNormal3d( 0.577350269189#, 0.577350269189#,-0.577350269189#) : glVertex3d( RADIUS, 0.0, 0.0) : glVertex3d( 0.0, 0.0,-RADIUS) : glVertex3d(0.0, RADIUS, 0.0)
      glNormal3d( 0.577350269189#,-0.577350269189#, 0.577350269189#) : glVertex3d( RADIUS, 0.0, 0.0) : glVertex3d( 0.0, 0.0, RADIUS) : glVertex3d(0.0,-RADIUS, 0.0)
      glNormal3d( 0.577350269189#,-0.577350269189#,-0.577350269189#) : glVertex3d( RADIUS, 0.0, 0.0) : glVertex3d( 0.0,-RADIUS, 0.0) : glVertex3d(0.0, 0.0,-RADIUS)
      glNormal3d(-0.577350269189#, 0.577350269189#, 0.577350269189#) : glVertex3d(-RADIUS, 0.0, 0.0) : glVertex3d( 0.0, 0.0, RADIUS) : glVertex3d(0.0, RADIUS, 0.0)
      glNormal3d(-0.577350269189#, 0.577350269189#,-0.577350269189#) : glVertex3d(-RADIUS, 0.0, 0.0) : glVertex3d( 0.0, RADIUS, 0.0) : glVertex3d(0.0, 0.0,-RADIUS)
      glNormal3d(-0.577350269189#,-0.577350269189#, 0.577350269189#) : glVertex3d(-RADIUS, 0.0, 0.0) : glVertex3d( 0.0,-RADIUS, 0.0) : glVertex3d(0.0, 0.0, RADIUS)
      glNormal3d(-0.577350269189#,-0.577350269189#,-0.577350269189#) : glVertex3d(-RADIUS, 0.0, 0.0) : glVertex3d( 0.0, 0.0,-RADIUS) : glVertex3d(0.0,-RADIUS, 0.0)
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
'/*
' * Compute lookup table of cos and sin values forming a cirle
' *
' * Notes:
' *    It is the responsibility of the caller to free these tables
' *    The size of the table is (n+1) to form a connected loop
' *    The last entry is exactly the same as the first
' *    The sign of n can be flipped to get the reverse loop
' */
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutCircleTable (BYREF sint() AS DOUBLE, BYREF cost() AS DOUBLE, BYVAL n AS LONG)

   LOCAL i AS LONG

   ' /* Table size, the sign of n flips the circle direction */

   LOCAL nSize AS LONG
   nSize = ABS(n)

   ' /* Determine the angle between samples */

   LOCAL angle AS DOUBLE
   IF n = 0 THEN n = 1
   angle = 2 * 3.14159265358979323846# / IIF(n = 0, 1, n)

   ' /* Allocate memory for n samples, plus duplicate of first entry at the end */
   REDIM sint(nSize) AS DOUBLE
   REDIM cost(nSize) AS DOUBLE

   ' /* Compute cos and sin around the circle */
   sint(0) = 0.0
   cost(0) = 1.0

   FOR i = 1 TO nSize - 1
      sint(i) = SIN(angle * i)
      cost(i) = COS(angle * i)
   NEXT

   ' /* Last sample is duplicate of the first */
   sint(nSize) = sint(0)
   cost(nSize) = cost(0)

END SUB
' ========================================================================================

' ========================================================================================
'/*
' * Draws a solid sphere
' */
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stacks AS LONG)

   LOCAL i, j AS LONG

   ' /* Adjust z and radius as stacks are drawn. */

   LOCAL z0, z1 AS DOUBLE
   LOCAL r0, r1 AS DOUBLE

   ' /* Pre-computed circle */

   DIM sint1(0) AS DOUBLE
   DIM cost1(0) AS DOUBLE
   DIM sint2(0) AS DOUBLE
   DIM cost2(0) AS DOUBLE

   AfxGlutCircleTable(sint1(), cost1(), -slices)
   AfxGlutCircleTable(sint2(), cost2(), stacks * 2)

   ' /* The top stack is covered with a triangle fan */

   z0 = 1.0
   z1 = cost2(IIF&(stacks > 0, 1, 0))
   r0 = 0.0
   r1 = sint2(IIF&(stacks > 0, 1, 0))

   glBegin(%GL_TRIANGLE_FAN)
      glNormal3d(0, 0, 1)
      glVertex3d(0, 0, radius)
      FOR j = slices TO 0 STEP -1
         glNormal3d(cost1(j)*r1,        sint1(j)*r1,        z1       )
         glVertex3d(cost1(j)*r1*radius, sint1(j)*r1*radius, z1*radius)
      NEXT
   glEnd

   ' /* Cover each stack with a quad strip, except the top and bottom stacks */

   FOR i = 1 TO stacks - 2
      z0 = z1 : z1 = cost2(i + 1)
      r0 = r1 : r1 = sint2(i + 1)
      glBegin(%GL_QUAD_STRIP)
         FOR j = 0 TO slices
            glNormal3d(cost1(j)*r1,        sint1(j)*r1,        z1       )
            glVertex3d(cost1(j)*r1*radius, sint1(j)*r1*radius, z1*radius)
            glNormal3d(cost1(j)*r0,        sint1(j)*r0,        z0       )
            glVertex3d(cost1(j)*r0*radius, sint1(j)*r0*radius, z0*radius)
         NEXT
      glEnd
   NEXT

   ' /* The bottom stack is covered with a triangle fan */

   z0 = z1
   r0 = r1

   glBegin(%GL_TRIANGLE_FAN)
      glNormal3d(0, 0, -1)
      glVertex3d(0, 0, -radius)
      FOR j = 0 TO slices
         glNormal3d(cost1(j)*r0,        sint1(j)*r0,        z0       )
         glVertex3d(cost1(j)*r0*radius, sint1(j)*r0*radius, z0*radius)
      NEXT
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
'/*
' * Draws a wire sphere
' */
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stacks AS LONG)

   LOCAL i, j AS LONG

   ' /* Adjust z and radius as stacks and slices are drawn. */

   LOCAL r AS DOUBLE
   LOCAL x, y, z AS DOUBLE

   ' /* Pre-computed circle */

   DIM sint1(0) AS DOUBLE
   DIM cost1(0) AS DOUBLE
   DIM sint2(0) AS DOUBLE
   DIM cost2(0) AS DOUBLE

   AfxGlutCircleTable(sint1(), cost1(), -slices)
   AfxGlutCircleTable(sint2(), cost2(), stacks * 2)

   ' /* Draw a line loop for each stack */

   FOR i = 1 TO stacks - 1
      z = cost2(i)
      r = sint2(i)
      glBegin(%GL_LINE_LOOP)
         FOR j = 0 TO slices
            x = cost1(j)
            y = sint1(j)
            glNormal3d(x, y, z)
            glVertex3d(x*r*radius, y*r*radius,z*radius)
         NEXT
      glEnd
   NEXT

   ' /* Draw a line loop for each slice */

   FOR i = 0 TO slices - 1
      glBegin(%GL_LINE_STRIP)
         FOR j = 0 TO stacks
            x = cost1(i)*sint2(j)
            y = sint1(i)*sint2(j)
            z = cost2(j)
            glNormal3d(x,y,z)
            glVertex3d(x*radius, y*radius,z*radius)
         NEXT
      glEnd
   NEXT

END SUB
' ========================================================================================

' ========================================================================================
'/*
' * Draws a solid cone
' */
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidCone (BYVAL dbase AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stacks AS LONG)

   LOCAL i, j AS LONG

   ' /* Step in z and radius as stacks are drawn. */

   LOCAL z0, z1 AS DOUBLE
   LOCAL r0, r1 AS DOUBLE

   LOCAL zStep, rStep AS DOUBLE
   zStep = height / IIF&(stacks > 0, stacks, 1)
   rStep = dbase / IIF&(stacks > 0, stacks, 1)

   ' /* Scaling factors for vertex normals */

   LOCAL cosn, sinn AS DOUBLE
   cosn = (height / SQR(height * height + dbase * dbase))
   sinn = (dbase  / SQR(height * height + dbase * dbase))

   ' /* Pre-computed circle */

   DIM sint(0) AS DOUBLE
   DIM cost(0) AS DOUBLE

   AfxGlutCircleTable(sint(), cost(), -slices)

   ' /* Cover the circular base with a triangle fan... */

   z0 = 0.0
   z1 = zStep

   r0 = dbase
   r1 = r0 - rStep

   glBegin(%GL_TRIANGLE_FAN)
      glNormal3d(0.0, 0.0, -1.0)
      glVertex3d(0.0, 0.0, z0)
      FOR j = 0 TO slices
         glVertex3d(cost(j)*r0, sint(j)*r0, z0)
      NEXT
   glEnd

   ' /* Cover each stack with a quad strip, except the top stack */

   FOR i = 0 TO stacks - 2
      glBegin(%GL_QUAD_STRIP)
         FOR j = 0 TO slices
            glNormal3d(cost(j)*sinn, sint(j)*sinn, cosn)
            glVertex3d(cost(j)*r0,   sint(j)*r0,   z0  )
            glVertex3d(cost(j)*r1,   sint(j)*r1,   z1  )
         NEXT
         z0 = z1 : z1 += zStep
         r0 = r1 : r1 -= rStep
      glEnd
   NEXT

   ' /* The top stack is covered with individual triangles */

   glBegin(%GL_TRIANGLES)
      glNormal3d(cost(0)*sinn, sint(0)*sinn, cosn)
      FOR j = 0 TO slices - 1
         glVertex3d(cost(j+0)*r0,   sint(j+0)*r0,   z0    )
         glVertex3d(0,              0,              height)
         glNormal3d(cost(j+1)*sinn, sint(j+1)*sinn, cosn  )
         glVertex3d(cost(j+1)*r0,   sint(j+1)*r0,   z0    )
      NEXT
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
'/*
' * Draws a wire cone
' */
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireCone (BYVAL dbase AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stacks AS LONG)

   LOCAL i, j AS LONG

   ' /* Step in z and radius as stacks are drawn. */

   LOCAL z, r AS DOUBLE

   z = 0.0
   r = dbase

   LOCAL zStep, rStep AS DOUBLE
   zStep = height / IIF&(stacks > 0, stacks, 1)
   rStep = dbase / IIF&(stacks > 0, stacks, 1)

   ' /* Scaling factors for vertex normals */

   LOCAL cosn, sinn AS DOUBLE
   cosn = (height / SQR(height * height + dbase * dbase))
   sinn = (dbase  / SQR(height * height + dbase * dbase))

   ' /* Pre-computed circle */

   DIM sint(0) AS DOUBLE
   DIM cost(0) AS DOUBLE

   AfxGlutCircleTable(sint(), cost(), -slices)

   ' /* Draw the stacks... */

   FOR i = 0 TO stacks - 1
      glBegin(%GL_LINE_LOOP)
         FOR j = 0 TO slices - 1
            glNormal3d(cost(j)*sinn, sint(j)*sinn, cosn)
            glVertex3d(cost(j)*r,    sint(j)*r,    z   )
         NEXT
      glEnd
      z += zStep
      r -= rStep
   NEXT

   ' /* Draw the slices */

   r = dbase

   glBegin(%GL_LINES)
      FOR j = 0 TO slices - 1
         glNormal3d(cost(j)*sinn, sint(j)*sinn, cosn  )
         glVertex3d(cost(j)*r,    sint(j)*r,    0.0   )
         glVertex3d(0.0,          0.0,          height)
      NEXT
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
'/*
' * Draws a solid cylinder
' */
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidCylinder (BYVAL radius AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stacks AS LONG)

   LOCAL i, j AS LONG

   ' /* Step in z and radius as stacks are drawn. */

   LOCAL z0, z1 AS DOUBLE
   LOCAL zStep AS DOUBLE

   zStep = height / IIF&(stacks > 0, stacks, 1)

   ' /* Pre-computed circle */

   DIM sint(0) AS DOUBLE
   DIM cost(0) AS DOUBLE

   AfxGlutCircleTable(sint(), cost(), -slices)

   ' /* Cover the base and top */

   glBegin(%GL_TRIANGLE_FAN)
      glNormal3d(0.0, 0.0, -1.0)
      glVertex3d(0.0, 0.0,  0.0)
      FOR j = 0 TO slices
         glVertex3d(cost(j)*radius, sint(j)*radius, 0.0)
      NEXT
   glEnd

   glBegin(%GL_TRIANGLE_FAN)
      glNormal3d(0.0, 0.0, 1.0)
      glVertex3d(0.0, 0.0, height)
      FOR j = slices TO 0 STEP - 1
         glVertex3d(cost(j)*radius, sint(j)*radius, height)
      NEXT
   glEnd

   ' /* Do the stacks */

   z0 = 0.0
   z1 = zStep

   FOR i = 1 TO stacks
      IF i = stacks THEN z1 = height
      glBegin(%GL_QUAD_STRIP)
         FOR j = 0 TO slices
            glNormal3d(cost(j),        sint(j),        0.0)
            glVertex3d(cost(j)*radius, sint(j)*radius, z0 )
            glVertex3d(cost(j)*radius, sint(j)*radius, z1 )
         NEXT
      glEnd
      z0 = z1 : z1 += zStep
   NEXT

END SUB
' ========================================================================================

' ========================================================================================
'/*
' * Draws a wire cylinder
' */
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireCylinder (BYVAL radius AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stacks AS LONG)

   LOCAL i, j AS LONG

   ' /* Step in z and radius as stacks are drawn. */

   LOCAL z AS DOUBLE
   z = 0.0
   LOCAL zStep AS DOUBLE
   zStep = height / IIF&(stacks > 0, stacks, 1)

   ' /* Pre-computed circle */

   DIM sint(0) AS DOUBLE
   DIM cost(0) AS DOUBLE

   AfxGlutCircleTable(sint(), cost(), -slices)

   ' /* Draw the stacks... */

   FOR i = 0 TO stacks
      IF i = stacks THEN z = height
      glBegin(%GL_LINE_LOOP)
         FOR j = 0 TO slices - 1
            glNormal3d(cost(j),        sint(j),        0.0)
            glVertex3d(cost(j)*radius, sint(j)*radius, z  )
         NEXT
      glEnd
      z += zStep
   NEXT

   ' /* Draw the slices */

   glBegin(%GL_LINES)
      FOR j = 0 TO slices - 1
         glNormal3d(cost(j),        sint(j),        0.0   )
         glVertex3d(cost(j)*radius, sint(j)*radius, 0.0   )
         glVertex3d(cost(j)*radius, sint(j)*radius, height)
      NEXT
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
' Renders a solid dodecahedron (12-sided regular solid) respectively.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidDodecahedron

   '/* Magic Numbers:  It is possible to create a dodecahedron by attaching two pentagons to each face of
   ' * of a cube.  The coordinates of the points are:
   ' *  (+-x,0, z);(+-1, 1, 1);(0, z, x)
   ' * where x =(-1 + sqrt(5))/2, z =(1 + sqrt(5))/2 or
   ' *       x = 0.61803398875 and z = 1.61803398875.
   '*/

   glBegin(%GL_POLYGON)
      glNormal3d( 0.0, 0.525731112119, 0.850650808354)
      glVertex3d( 0.0, 1.61803398875, 0.61803398875)
      glVertex3d(-1.0, 1.0, 1.0)
      glVertex3d(-0.61803398875, 0.0, 1.61803398875)
      glVertex3d( 0.61803398875, 0.0, 1.61803398875)
      glVertex3d( 1.0, 1.0, 1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d( 0.0, 0.525731112119, -0.850650808354)
      glVertex3d( 0.0, 1.61803398875, -0.61803398875)
      glVertex3d( 1.0, 1.0, -1.0)
      glVertex3d( 0.61803398875, 0.0, -1.61803398875)
      glVertex3d(-0.61803398875, 0.0, -1.61803398875)
      glVertex3d(-1.0, 1.0, -1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d( 0.0, -0.525731112119, 0.850650808354)
      glVertex3d( 0.0, -1.61803398875, 0.61803398875)
      glVertex3d( 1.0, -1.0, 1.0)
      glVertex3d( 0.61803398875, 0.0, 1.61803398875)
      glVertex3d(-0.61803398875, 0.0, 1.61803398875)
      glVertex3d(-1.0, -1.0, 1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d( 0.0, -0.525731112119, -0.850650808354)
      glVertex3d( 0.0, -1.61803398875, -0.61803398875)
      glVertex3d(-1.0, -1.0, -1.0)
      glVertex3d(-0.61803398875, 0.0, -1.61803398875)
      glVertex3d( 0.61803398875, 0.0, -1.61803398875)
      glVertex3d( 1.0, -1.0, -1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d( 0.850650808354, 0.0, 0.525731112119)
      glVertex3d( 0.61803398875, 0.0, 1.61803398875)
      glVertex3d( 1.0, -1.0, 1.0)
      glVertex3d( 1.61803398875, -0.61803398875, 0.0)
      glVertex3d( 1.61803398875, 0.61803398875, 0.0)
      glVertex3d( 1.0, 1.0, 1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d(-0.850650808354, 0.0, 0.525731112119)
      glVertex3d(-0.61803398875, 0.0, 1.61803398875)
      glVertex3d(-1.0, 1.0, 1.0)
      glVertex3d(-1.61803398875, 0.61803398875, 0.0)
      glVertex3d(-1.61803398875, -0.61803398875, 0.0)
      glVertex3d(-1.0, -1.0, 1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d( 0.850650808354, 0.0, -0.525731112119)
      glVertex3d( 0.61803398875, 0.0, -1.61803398875)
      glVertex3d( 1.0, 1.0, -1.0)
      glVertex3d( 1.61803398875, 0.61803398875, 0.0)
      glVertex3d( 1.61803398875, -0.61803398875, 0.0)
      glVertex3d( 1.0, -1.0, -1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d(-0.850650808354, 0.0, -0.525731112119)
      glVertex3d(-0.61803398875, 0.0, -1.61803398875)
      glVertex3d(-1.0, -1.0, -1.0)
      glVertex3d(-1.61803398875, -0.61803398875, 0.0)
      glVertex3d(-1.61803398875, 0.61803398875, 0.0)
      glVertex3d(-1.0, 1.0, -1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d( 0.525731112119, 0.850650808354, 0.0)
      glVertex3d( 1.61803398875, 0.61803398875, 0.0)
      glVertex3d( 1.0, 1.0, -1.0)
      glVertex3d(0.0, 1.61803398875, -0.61803398875)
      glVertex3d(0.0, 1.61803398875, 0.61803398875)
      glVertex3d( 1.0, 1.0, 1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d( 0.525731112119, -0.850650808354, 0.0)
      glVertex3d( 1.61803398875, -0.61803398875, 0.0)
      glVertex3d( 1.0, -1.0, 1.0)
      glVertex3d(0.0, -1.61803398875, 0.61803398875)
      glVertex3d(0.0, -1.61803398875, -0.61803398875)
      glVertex3d( 1.0, -1.0, -1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d(-0.525731112119, 0.850650808354, 0.0)
      glVertex3d(-1.61803398875, 0.61803398875, 0.0)
      glVertex3d(-1.0, 1.0, 1.0)
      glVertex3d(0.0, 1.61803398875, 0.61803398875)
      glVertex3d(0.0, 1.61803398875, -0.61803398875)
      glVertex3d(-1.0, 1.0, -1.0)
   glEnd

   glBegin(%GL_POLYGON)
      glNormal3d(-0.525731112119, -0.850650808354, 0.0)
      glVertex3d(-1.61803398875, -0.61803398875, 0.0)
      glVertex3d(-1.0, -1.0, -1.0)
      glVertex3d(0.0, -1.61803398875, -0.61803398875)
      glVertex3d(0.0, -1.61803398875, 0.61803398875)
      glVertex3d(-1.0, -1.0, 1.0)
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
' Renders a wireframe dodecahedron (12-sided regular solid) respectively.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireDodecahedron

   '/* Magic Numbers:  It is possible to create a dodecahedron by attaching two pentagons to each face of
   ' * of a cube.  The coordinates of the points are:
   ' *   (+-x,0, z); (+-1, 1, 1); (0, z, x )
   ' * where x = (-1 + sqrt(5))/2, z = (1 + sqrt(5))/2  or
   ' *       x = 0.61803398875 and z = 1.61803398875.
   ' */
   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.0, 0.525731112119, 0.850650808354)
      glVertex3d (0.0, 1.61803398875, 0.61803398875)
      glVertex3d(-1.0, 1.0, 1.0 )
      glVertex3d(-0.61803398875, 0.0, 1.61803398875)
      glVertex3d(0.61803398875, 0.0, 1.61803398875)
      glVertex3d(1.0, 1.0, 1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.0, 0.525731112119, -0.850650808354)
      glVertex3d(0.0, 1.61803398875, -0.61803398875)
      glVertex3d(1.0, 1.0, -1.0)
      glVertex3d(0.61803398875, 0.0, -1.61803398875)
      glVertex3d(-0.61803398875, 0.0, -1.61803398875)
      glVertex3d(-1.0, 1.0, -1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.0, -0.525731112119, 0.850650808354)
      glVertex3d(0.0, -1.61803398875, 0.61803398875)
      glVertex3d(1.0, -1.0, 1.0)
      glVertex3d(0.61803398875, 0.0, 1.61803398875)
      glVertex3d( -0.61803398875, 0.0, 1.61803398875)
      glVertex3d(-1.0, -1.0, 1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.0, -0.525731112119, -0.850650808354)
      glVertex3d(0.0, -1.61803398875, -0.61803398875)
      glVertex3d(-1.0, -1.0, -1.0)
      glVertex3d(-0.61803398875, 0.0, -1.61803398875)
      glVertex3d(0.61803398875, 0.0, -1.61803398875)
      glVertex3d(1.0, -1.0, -1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.850650808354, 0.0, 0.525731112119)
      glVertex3d(0.61803398875, 0.0, 1.61803398875)
      glVertex3d(1.0, -1.0, 1.0)
      glVertex3d(1.61803398875, -0.61803398875, 0.0)
      glVertex3d(1.61803398875, 0.61803398875, 0.0)
      glVertex3d(1.0, 1.0, 1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(-0.850650808354, 0.0, 0.525731112119)
      glVertex3d(-0.61803398875, 0.0, 1.61803398875)
      glVertex3d(-1.0, 1.0, 1.0)
      glVertex3d(-1.61803398875, 0.61803398875, 0.0)
      glVertex3d(-1.61803398875, -0.61803398875, 0.0)
      glVertex3d(-1.0, -1.0, 1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.850650808354, 0.0, -0.525731112119)
      glVertex3d(0.61803398875, 0.0, -1.61803398875)
      glVertex3d(1.0, 1.0, -1.0)
      glVertex3d(1.61803398875, 0.61803398875, 0.0)
      glVertex3d(1.61803398875, -0.61803398875, 0.0)
      glVertex3d(1.0, -1.0, -1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(-0.850650808354, 0.0, -0.525731112119)
      glVertex3d(-0.61803398875, 0.0, -1.61803398875)
      glVertex3d(-1.0, -1.0, -1.0)
      glVertex3d(-1.61803398875, -0.61803398875, 0.0)
      glVertex3d(-1.61803398875,  0.61803398875, 0.0)
      glVertex3d(-1.0, 1.0, -1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.525731112119, 0.850650808354, 0.0)
      glVertex3d(1.61803398875, 0.61803398875, 0.0)
      glVertex3d(1.0, 1.0, -1.0)
      glVertex3d(0.0, 1.61803398875, -0.61803398875)
      glVertex3d(0.0, 1.61803398875, 0.61803398875)
      glVertex3d(1.0, 1.0, 1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(0.525731112119, -0.850650808354, 0.0)
      glVertex3d(1.61803398875, -0.61803398875, 0.0)
      glVertex3d(1.0, -1.0, 1.0)
      glVertex3d(0.0, -1.61803398875, 0.61803398875)
      glVertex3d(0.0, -1.61803398875, -0.61803398875)
      glVertex3d(1.0, -1.0, -1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(-0.525731112119, 0.850650808354, 0.0)
      glVertex3d(-1.61803398875, 0.61803398875, 0.0)
      glVertex3d(-1.0, 1.0, 1.0)
      glVertex3d(0.0, 1.61803398875, 0.61803398875)
      glVertex3d(0.0, 1.61803398875, -0.61803398875)
      glVertex3d(-1.0, 1.0, -1.0)
   glEnd

   glBegin(%GL_LINE_LOOP)
      glNormal3d(-0.525731112119, -0.850650808354, 0.0)
      glVertex3d(-1.61803398875, -0.61803398875, 0.0)
      glVertex3d(-1.0, -1.0, -1.0)
      glVertex3d(0.0, -1.61803398875, -0.61803398875)
      glVertex3d(0.0, -1.61803398875, 0.61803398875)
      glVertex3d(-1.0, -1.0, 1.0)
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
' Renders a solid tetrahedron (4-sided regular solid) respectively.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidTetrahedron

   DIM tet_r(3, 2) AS STATIC DOUBLE
   tet_r(0, 0) =  1.0#            : tet_r(0, 1) =  0.0#            : tet_r(0, 2) =  0.0#
   tet_r(1, 0) = -0.333333333333# : tet_r(1, 1) =  0.942809041582# : tet_r(1, 2) =  0.0#
   tet_r(2, 0) = -0.333333333333# : tet_r(2, 1) = -0.471404520791# : tet_r(2, 2) =  0.816496580928#
   tet_r(3, 0) = -0.333333333333# : tet_r(3, 1) = -0.471404520791# : tet_r(3, 2) = -0.816496580928#

   glBegin(%GL_TRIANGLES)
      glNormal3d(-tet_r(0, 0), -tet_r(0, 1), -tet_r(0, 2))
      glVertex3d(tet_r(1, 0), tet_r(1, 1), tet_r(1, 2))
      glVertex3d(tet_r(3, 0), tet_r(3, 1), tet_r(3, 2))
      glVertex3d(tet_r(2, 0), tet_r(2, 1), tet_r(2, 2))

      glNormal3d(-tet_r(1, 0), -tet_r(1, 1), -tet_r(1, 2))
      glVertex3d(tet_r(0, 0), tet_r(0, 1), tet_r(0, 2))
      glVertex3d(tet_r(2, 0), tet_r(2, 1), tet_r(2, 2))
      glVertex3d(tet_r(3, 0), tet_r(3, 1), tet_r(3, 2))

      glNormal3d(-tet_r(2, 0), -tet_r(2, 1), -tet_r(2, 2))
      glVertex3d(tet_r(0, 0), tet_r(0, 1), tet_r(0, 2))
      glVertex3d(tet_r(3, 0), tet_r(3, 1), tet_r(3, 2))
      glVertex3d(tet_r(1, 0), tet_r(1, 1), tet_r(1, 2))

      glNormal3d(-tet_r(3, 0), -tet_r(3, 1), -tet_r(3, 2))
      glVertex3d(tet_r(0, 0), tet_r(0, 1), tet_r(0, 2))
      glVertex3d(tet_r(1, 0), tet_r(1, 1), tet_r(1, 2))
      glVertex3d(tet_r(2, 0), tet_r(2, 1), tet_r(2, 2))
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
' Renders a wire frame tetrahedron (4-sided regular solid) respectively.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireTetrahedron

   DIM tet_r(3, 2) AS STATIC DOUBLE
   tet_r(0, 0) =  1.0#            : tet_r(0, 1) =  0.0#            : tet_r(0, 2) =  0.0#
   tet_r(1, 0) = -0.333333333333# : tet_r(1, 1) =  0.942809041582# : tet_r(1, 2) =  0.0#
   tet_r(2, 0) = -0.333333333333# : tet_r(2, 1) = -0.471404520791# : tet_r(2, 2) =  0.816496580928#
   tet_r(3, 0) = -0.333333333333# : tet_r(3, 1) = -0.471404520791# : tet_r(3, 2) = -0.816496580928#

   glBegin(%GL_LINE_LOOP)
      glNormal3d(-tet_r(0, 0), -tet_r(0, 1), -tet_r(0, 2))
      glVertex3d(tet_r(1, 0), tet_r(1, 1), tet_r(1, 2))
      glVertex3d(tet_r(3, 0), tet_r(3, 1), tet_r(3, 2))
      glVertex3d(tet_r(2, 0), tet_r(2, 1), tet_r(2, 2))

      glNormal3d(-tet_r(1, 0), -tet_r(1, 1), -tet_r(1, 2))
      glVertex3d(tet_r(0, 0), tet_r(0, 1), tet_r(0, 2))
      glVertex3d(tet_r(2, 0), tet_r(2, 1), tet_r(2, 2))
      glVertex3d(tet_r(3, 0), tet_r(3, 1), tet_r(3, 2))

      glNormal3d(-tet_r(2, 0), -tet_r(2, 1), -tet_r(2, 2))
      glVertex3d(tet_r(0, 0), tet_r(0, 1), tet_r(0, 2))
      glVertex3d(tet_r(3, 0), tet_r(3, 1), tet_r(3, 2))
      glVertex3d(tet_r(1, 0), tet_r(1, 1), tet_r(1, 2))

      glNormal3d(-tet_r(3, 0), -tet_r(3, 1), -tet_r(3, 2))
      glVertex3d(tet_r(0, 0), tet_r(0, 1), tet_r(0, 2))
      glVertex3d(tet_r(1, 0), tet_r(1, 1), tet_r(1, 2))
      glVertex3d(tet_r(2, 0), tet_r(2, 1), tet_r(2, 2))
   glEnd

END SUB
' ========================================================================================

' ========================================================================================
' Renders a torus (doughnut)
' Adapted from glut.
' ========================================================================================
SUB AfxGlutDoughnut (BYVAL innerRadius AS SINGLE, BYVAL outerRadius AS SINGLE , BYVAL nsides AS LONG, BYVAL rings AS LONG)

  LOCAL i AS LONG
  LOCAL j AS LONG
  LOCAL theta AS SINGLE
  LOCAL phi AS SINGLE
  LOCAL theta1 AS SINGLE
  LOCAL cosTheta AS SINGLE
  LOCAL sinTheta AS SINGLE
  LOCAL cosTheta1 AS SINGLE
  LOCAL sinTheta1 AS SINGLE
  LOCAL ringDelta AS SINGLE
  LOCAL sideDelta AS SINGLE  '// Double

  ringDelta = 2.0 * 3.14159265358979323846 / rings
  sideDelta = 2.0 * 3.14159265358979323846 / nsides
  theta = 0.0
  cosTheta = 1.0
  sinTheta = 0.0

  FOR i = rings - 1 TO 0 STEP -1
    theta1 = theta + ringDelta
    cosTheta1 = COS(theta1)
    sinTheta1 = SIN(theta1)
    glBegin(%GL_QUAD_STRIP)
    phi = 0.0
    FOR j = nsides TO 0 STEP -1
      LOCAL cosPhi AS SINGLE
      LOCAL sinPhi AS SINGLE
      LOCAL dist AS SINGLE
      phi += sideDelta
      cosPhi = COS(phi)
      sinPhi = SIN(phi)
      dist = outerRadius + innerRadius * cosPhi
      glNormal3f(cosTheta1 * cosPhi, -sinTheta1 * cosPhi, sinPhi)
      glVertex3f(cosTheta1 * dist, -sinTheta1 * dist, innerRadius * sinPhi)
      glNormal3f(cosTheta * cosPhi, -sinTheta * cosPhi, sinPhi)
      glVertex3f(cosTheta * dist, -sinTheta * dist, innerRadius * sinPhi)
    NEXT
    glEnd
    theta = theta1
    cosTheta = cosTheta1
    sinTheta = sinTheta1
  NEXT
END SUB
' ========================================================================================

' ========================================================================================
' Renders a solid torus (doughnut)
' Adapted from glut.
' ========================================================================================
SUB AfxGlutWireTorus (BYVAL innerRadius AS DOUBLE, BYVAL outerRadius AS DOUBLE, BYVAL nsides AS LONG, BYVAL rings AS LONG)
   glPushAttrib(%GL_POLYGON_BIT)
   glPolygonMode(%GL_FRONT_AND_BACK, %GL_LINE)
   AfxGlutDoughnut(innerRadius, outerRadius, nsides, rings)
   glPopAttrib
END SUB
' ========================================================================================

' ========================================================================================
' Renders a wireframe torus (doughnut)
' Adapted from glut.
' ========================================================================================
SUB AfxGlutSolidTorus(BYVAL innerRadius AS DOUBLE, outerRadius AS DOUBLE, BYVAL nsides AS LONG, BYVAL rings AS LONG)
   AfxGlutDoughnut(innerRadius, outerRadius, nsides, rings)
END SUB
' ========================================================================================

' ========================================================================================
' Renders wireframe icosahedron The icosahedron is centered at the modeling coordinates
' origin and has a radius of 1.0.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireIcosahedron

   LOCAL i AS LONG
   STATIC bArraysInitialized AS LONG

   IF bArraysInitialized = 0 THEN

      DIM icos_r(11, 2) AS STATIC DOUBLE

      icos_r( 0, 0) =  1.0            : icos_r( 0, 1) =  0.0            : icos_r( 0, 2) =  0.0
      icos_r( 1, 0) =  0.447213595500 : icos_r( 1, 1) =  0.894427191000 : icos_r( 1, 2) =  0.0
      icos_r( 2, 0) =  0.447213595500 : icos_r( 2, 1) =  0.276393202252 : icos_r( 2, 2) =  0.850650808354
      icos_r( 3, 0) =  0.447213595500 : icos_r( 3, 1) = -0.723606797748 : icos_r( 3, 2) =  0.525731112119
      icos_r( 4, 0) =  0.447213595500 : icos_r( 4, 1) = -0.723606797748 : icos_r( 4, 2) = -0.525731112119
      icos_r( 5, 0) =  0.447213595500 : icos_r( 5, 1) =  0.276393202252 : icos_r( 5, 2) = -0.850650808354
      icos_r( 6, 0) = -0.447213595500 : icos_r( 6, 1) = -0.894427191000 : icos_r( 6, 2) = -0.0
      icos_r( 7, 0) = -0.447213595500 : icos_r( 7, 1) = -0.276393202252 : icos_r( 7, 2) =  0.850650808354
      icos_r( 8, 0) = -0.447213595500 : icos_r( 8, 1) =  0.723606797748 : icos_r( 8, 2) =  0.525731112119
      icos_r( 9, 0) = -0.447213595500 : icos_r( 9, 1) =  0.723606797748 : icos_r( 9, 2) = -0.525731112119
      icos_r(10, 0) = -0.447213595500 : icos_r(10, 1) = -0.276393202252 : icos_r(10, 2) = -0.850650808354
      icos_r(11, 0) = -1.0            : icos_r(11, 1) =  0.0            : icos_r(11, 2) =  0.0

      DIM icos_v(19, 2) AS STATIC LONG

      icos_v( 0, 0) =  0 : icos_v( 0, 1) =  1 : icos_v( 0, 2) =  2
      icos_v( 1, 0) =  0 : icos_v( 1, 1) =  2 : icos_v( 1, 2) =  3
      icos_v( 2, 0) =  0 : icos_v( 2, 1) =  3 : icos_v( 2, 2) =  4
      icos_v( 3, 0) =  0 : icos_v( 3, 1) =  4 : icos_v( 3, 2) =  5
      icos_v( 4, 0) =  0 : icos_v( 4, 1) =  5 : icos_v( 4, 2) =  1
      icos_v( 5, 0) =  1 : icos_v( 5, 1) =  8 : icos_v( 5, 2) =  2
      icos_v( 6, 0) =  2 : icos_v( 6, 1) =  7 : icos_v( 6, 2) =  3
      icos_v( 7, 0) =  3 : icos_v( 7, 1) =  6 : icos_v( 7, 2) =  4
      icos_v( 8, 0) =  4 : icos_v( 8, 1) = 10 : icos_v( 8, 2) =  5
      icos_v( 9, 0) =  5 : icos_v( 9, 1) =  9 : icos_v( 9, 2) =  1
      icos_v(10, 0) =  1 : icos_v(10, 1) =  9 : icos_v(10, 2) =  8
      icos_v(11, 0) =  2 : icos_v(11, 1) =  8 : icos_v(11, 2) =  7
      icos_v(12, 0) =  3 : icos_v(12, 1) =  7 : icos_v(12, 2) =  6
      icos_v(13, 0) =  4 : icos_v(13, 1) =  6 : icos_v(13, 2) = 10
      icos_v(14, 0) =  5 : icos_v(14, 1) = 10 : icos_v(14, 2) =  9
      icos_v(15, 0) = 11 : icos_v(15, 1) =  9 : icos_v(15, 2) = 10
      icos_v(16, 0) = 11 : icos_v(16, 1) =  8 : icos_v(16, 2) =  9
      icos_v(17, 0) = 11 : icos_v(17, 1) =  7 : icos_v(17, 2) =  8
      icos_v(18, 0) = 11 : icos_v(18, 1) =  6 : icos_v(18, 2) =  7
      icos_v(19, 0) = 11 : icos_v(19, 1) = 10 : icos_v(19, 2) =  6

   END IF
   bArraysInitialized = 1

   FOR i = 0 TO 19
      REDIM normal(2) AS DOUBLE
      normal(0) = (icos_r(icos_v(i,1),1) - icos_r(icos_v(i,0),1)) * _
                  (icos_r(icos_v(i,2),2) - icos_r(icos_v(i,0),2)) - _
                  (icos_r(icos_v(i,1),2) - icos_r(icos_v(i,0),2)) * _
                  (icos_r(icos_v(i,2),1) - icos_r(icos_v(i,0),1))

      normal(1) = (icos_r(icos_v(i,1),2) - icos_r(icos_v(i,0),2)) * _
                  (icos_r(icos_v(i,2),0) - icos_r(icos_v(i,0),0)) - _
                  (icos_r(icos_v(i,1),0) - icos_r(icos_v(i,0),0)) * _
                  (icos_r(icos_v(i,2),2) - icos_r(icos_v(i,0),2))

      normal(2) = (icos_r(icos_v(i,1),0) - icos_r(icos_v(i,0),0)) * _
                  (icos_r(icos_v(i,2),1) - icos_r(icos_v(i,0),1)) - _
                  (icos_r(icos_v(i,1),1) - icos_r(icos_v(i,0),1)) * _
                  (icos_r(icos_v(i,2),0) - icos_r(icos_v(i,0),0))
      glBegin(%GL_LINE_LOOP)
         glNormal3dv(normal(0))
         glVertex3dv(icos_r(icos_v(i, 0)))
         glVertex3dv(icos_r(icos_v(i, 1)))
         glVertex3dv(icos_r(icos_v(i, 2)))
      glEnd
   NEXT

END SUB
' ========================================================================================

' ========================================================================================
' Renders solid icosahedron The icosahedron is centered at the modeling coordinates
' origin and has a radius of 1.0.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidIcosahedron

   LOCAL i AS LONG
   STATIC bArraysInitialized AS LONG

   IF bArraysInitialized = 0 THEN

      DIM icos_r(11, 2) AS STATIC DOUBLE

      icos_r( 0, 0) =  1.0            : icos_r( 0, 1) =  0.0            : icos_r( 0, 2) =  0.0
      icos_r( 1, 0) =  0.447213595500 : icos_r( 1, 1) =  0.894427191000 : icos_r( 1, 2) =  0.0
      icos_r( 2, 0) =  0.447213595500 : icos_r( 2, 1) =  0.276393202252 : icos_r( 2, 2) =  0.850650808354
      icos_r( 3, 0) =  0.447213595500 : icos_r( 3, 1) = -0.723606797748 : icos_r( 3, 2) =  0.525731112119
      icos_r( 4, 0) =  0.447213595500 : icos_r( 4, 1) = -0.723606797748 : icos_r( 4, 2) = -0.525731112119
      icos_r( 5, 0) =  0.447213595500 : icos_r( 5, 1) =  0.276393202252 : icos_r( 5, 2) = -0.850650808354
      icos_r( 6, 0) = -0.447213595500 : icos_r( 6, 1) = -0.894427191000 : icos_r( 6, 2) = -0.0
      icos_r( 7, 0) = -0.447213595500 : icos_r( 7, 1) = -0.276393202252 : icos_r( 7, 2) =  0.850650808354
      icos_r( 8, 0) = -0.447213595500 : icos_r( 8, 1) =  0.723606797748 : icos_r( 8, 2) =  0.525731112119
      icos_r( 9, 0) = -0.447213595500 : icos_r( 9, 1) =  0.723606797748 : icos_r( 9, 2) = -0.525731112119
      icos_r(10, 0) = -0.447213595500 : icos_r(10, 1) = -0.276393202252 : icos_r(10, 2) = -0.850650808354
      icos_r(11, 0) = -1.0            : icos_r(11, 1) =  0.0            : icos_r(11, 2) =  0.0

      DIM icos_v(19, 2) AS STATIC LONG

      icos_v( 0, 0) =  0 : icos_v( 0, 1) =  1 : icos_v( 0, 2) =  2
      icos_v( 1, 0) =  0 : icos_v( 1, 1) =  2 : icos_v( 1, 2) =  3
      icos_v( 2, 0) =  0 : icos_v( 2, 1) =  3 : icos_v( 2, 2) =  4
      icos_v( 3, 0) =  0 : icos_v( 3, 1) =  4 : icos_v( 3, 2) =  5
      icos_v( 4, 0) =  0 : icos_v( 4, 1) =  5 : icos_v( 4, 2) =  1
      icos_v( 5, 0) =  1 : icos_v( 5, 1) =  8 : icos_v( 5, 2) =  2
      icos_v( 6, 0) =  2 : icos_v( 6, 1) =  7 : icos_v( 6, 2) =  3
      icos_v( 7, 0) =  3 : icos_v( 7, 1) =  6 : icos_v( 7, 2) =  4
      icos_v( 8, 0) =  4 : icos_v( 8, 1) = 10 : icos_v( 8, 2) =  5
      icos_v( 9, 0) =  5 : icos_v( 9, 1) =  9 : icos_v( 9, 2) =  1
      icos_v(10, 0) =  1 : icos_v(10, 1) =  9 : icos_v(10, 2) =  8
      icos_v(11, 0) =  2 : icos_v(11, 1) =  8 : icos_v(11, 2) =  7
      icos_v(12, 0) =  3 : icos_v(12, 1) =  7 : icos_v(12, 2) =  6
      icos_v(13, 0) =  4 : icos_v(13, 1) =  6 : icos_v(13, 2) = 10
      icos_v(14, 0) =  5 : icos_v(14, 1) = 10 : icos_v(14, 2) =  9
      icos_v(15, 0) = 11 : icos_v(15, 1) =  9 : icos_v(15, 2) = 10
      icos_v(16, 0) = 11 : icos_v(16, 1) =  8 : icos_v(16, 2) =  9
      icos_v(17, 0) = 11 : icos_v(17, 1) =  7 : icos_v(17, 2) =  8
      icos_v(18, 0) = 11 : icos_v(18, 1) =  6 : icos_v(18, 2) =  7
      icos_v(19, 0) = 11 : icos_v(19, 1) = 10 : icos_v(19, 2) =  6

   END IF
   bArraysInitialized = 1

   FOR i = 0 TO 19
      REDIM normal(2) AS DOUBLE
      normal(0) = (icos_r(icos_v(i,1),1) - icos_r(icos_v(i,0),1)) * _
                  (icos_r(icos_v(i,2),2) - icos_r(icos_v(i,0),2)) - _
                  (icos_r(icos_v(i,1),2) - icos_r(icos_v(i,0),2)) * _
                  (icos_r(icos_v(i,2),1) - icos_r(icos_v(i,0),1))

      normal(1) = (icos_r(icos_v(i,1),2) - icos_r(icos_v(i,0),2)) * _
                  (icos_r(icos_v(i,2),0) - icos_r(icos_v(i,0),0)) - _
                  (icos_r(icos_v(i,1),0) - icos_r(icos_v(i,0),0)) * _
                  (icos_r(icos_v(i,2),2) - icos_r(icos_v(i,0),2))

      normal(2) = (icos_r(icos_v(i,1),0) - icos_r(icos_v(i,0),0)) * _
                  (icos_r(icos_v(i,2),1) - icos_r(icos_v(i,0),1)) - _
                  (icos_r(icos_v(i,1),1) - icos_r(icos_v(i,0),1)) * _
                  (icos_r(icos_v(i,2),0) - icos_r(icos_v(i,0),0))
      glBegin(%GL_TRIANGLES)
         glNormal3dv(normal(0))
         glVertex3dv(icos_r(icos_v(i, 0)))
         glVertex3dv(icos_r(icos_v(i, 1)))
         glVertex3dv(icos_r(icos_v(i, 2)))
      glEnd
   NEXT

END SUB
' ========================================================================================

' ========================================================================================
' This function draws a wireframe dodecahedron whose facets are rhombic and whose vertices
' are at unit radius. No facet lies normal to any coordinate axes. The polyhedron is
' centered at the origin.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutWireRhombicDodecahedron

   STATIC bArraysInitialized AS LONG

   IF bArraysInitialized = 0 THEN

      DIM rdod_r(13, 2) AS STATIC DOUBLE

      rdod_r( 0, 0) =  0.0            : rdod_r( 0, 1) =  0.0            : rdod_r( 0, 2) =  1.0
      rdod_r( 1, 0) =  0.707106781187 : rdod_r( 1, 1) =  0.000000000000 : rdod_r( 1, 2) =  0.5
      rdod_r( 2, 0) =  0.000000000000 : rdod_r( 2, 1) =  0.707106781187 : rdod_r( 2, 2) =  0.5
      rdod_r( 3, 0) = -0.707106781187 : rdod_r( 3, 1) =  0.000000000000 : rdod_r( 3, 2) =  0.5
      rdod_r( 4, 0) =  0.000000000000 : rdod_r( 4, 1) = -0.707106781187 : rdod_r( 4, 2) =  0.5
      rdod_r( 5, 0) =  0.707106781187 : rdod_r( 5, 1) =  0.707106781187 : rdod_r( 5, 2) =  0.0
      rdod_r( 6, 0) = -0.707106781187 : rdod_r( 6, 1) =  0.707106781187 : rdod_r( 6, 2) =  0.0
      rdod_r( 7, 0) = -0.707106781187 : rdod_r( 7, 1) = -0.707106781187 : rdod_r( 7, 2) =  0.0
      rdod_r( 8, 0) =  0.707106781187 : rdod_r( 8, 1) = -0.707106781187 : rdod_r( 8, 2) =  0.0
      rdod_r( 9, 0) =  0.707106781187 : rdod_r( 9, 1) =  0.000000000000 : rdod_r( 9, 2) = -0.5
      rdod_r(10, 0) =  0.000000000000 : rdod_r(10, 1) =  0.707106781187 : rdod_r(10, 2) = -0.5
      rdod_r(11, 0) = -0.707106781187 : rdod_r(11, 1) =  0.000000000000 : rdod_r(11, 2) = -0.5
      rdod_r(12, 0) =  0.000000000000 : rdod_r(12, 1) = -0.707106781187 : rdod_r(12, 2) = -0.5
      rdod_r(13, 0) =  0.0            : rdod_r(13, 1) =  0.0            : rdod_r(13, 2) = -1.0

      DIM rdod_v(11, 3) AS STATIC DOUBLE

      rdod_v( 0, 0) = 0 : rdod_v( 0, 1) =  1 : rdod_v( 0, 2) =  5 : rdod_v( 0, 3) =  2
      rdod_v( 1, 0) = 0 : rdod_v( 1, 1) =  2 : rdod_v( 1, 2) =  6 : rdod_v( 1, 3) =  3
      rdod_v( 2, 0) = 0 : rdod_v( 2, 1) =  3 : rdod_v( 2, 2) =  7 : rdod_v( 2, 3) =  4
      rdod_v( 3, 0) = 0 : rdod_v( 3, 1) =  4 : rdod_v( 3, 2) =  8 : rdod_v( 3, 3) =  1
      rdod_v( 4, 0) = 5 : rdod_v( 4, 1) = 10 : rdod_v( 4, 2) =  6 : rdod_v( 4, 3) =  2
      rdod_v( 5, 0) = 6 : rdod_v( 5, 1) = 11 : rdod_v( 5, 2) =  7 : rdod_v( 5, 3) =  3
      rdod_v( 6, 0) = 7 : rdod_v( 6, 1) = 12 : rdod_v( 6, 2) =  8 : rdod_v( 6, 3) =  4
      rdod_v( 7, 0) = 8 : rdod_v( 7, 1) =  9 : rdod_v( 7, 2) =  5 : rdod_v( 7, 3) =  1
      rdod_v( 8, 0) = 5 : rdod_v( 8, 1) =  9 : rdod_v( 8, 2) = 13 : rdod_v( 8, 3) = 10
      rdod_v( 9, 0) = 6 : rdod_v( 9, 1) = 10 : rdod_v( 9, 2) = 13 : rdod_v( 9, 3) = 11
      rdod_v(10, 0) = 7 : rdod_v(10, 1) = 11 : rdod_v(10, 2) = 13 : rdod_v(10, 3) = 12
      rdod_v(11, 0) = 8 : rdod_v(11, 1) = 12 : rdod_v(11, 2) = 13 : rdod_v(11, 3) =  9

      DIM rdod_n(11, 2) AS STATIC DOUBLE

      rdod_n( 0, 0) =  0.353553390594 : rdod_n( 0, 1) =  0.353553390594 : rdod_n( 0, 2) =  0.5
      rdod_n( 1, 0) = -0.353553390594 : rdod_n( 1, 1) =  0.353553390594 : rdod_n( 1, 2) =  0.5
      rdod_n( 2, 0) = -0.353553390594 : rdod_n( 2, 1) = -0.353553390594 : rdod_n( 2, 2) =  0.5
      rdod_n( 3, 0) =  0.353553390594 : rdod_n( 3, 1) = -0.353553390594 : rdod_n( 3, 2) =  0.5
      rdod_n( 4, 0) =  0.000000000000 : rdod_n( 4, 1) =  1.000000000000 : rdod_n( 4, 2) =  0.0
      rdod_n( 5, 0) = -1.000000000000 : rdod_n( 5, 1) =  0.000000000000 : rdod_n( 5, 2) =  0.0
      rdod_n( 6, 0) =  0.000000000000 : rdod_n( 6, 1) = -1.000000000000 : rdod_n( 6, 2) =  0.0
      rdod_n( 7, 0) =  1.000000000000 : rdod_n( 7, 1) =  0.000000000000 : rdod_n( 7, 2) =  0.0
      rdod_n( 8, 0) =  0.353553390594 : rdod_n( 8, 1) =  0.353553390594 : rdod_n( 8, 2) = -0.5
      rdod_n( 9, 0) = -0.353553390594 : rdod_n( 9, 1) =  0.353553390594 : rdod_n( 9, 2) = -0.5
      rdod_n(10, 0) = -0.353553390594 : rdod_n(10, 1) = -0.353553390594 : rdod_n(10, 2) = -0.5
      rdod_n(11, 0) =  0.353553390594 : rdod_n(11, 1) = -0.353553390594 : rdod_n(11, 2) = -0.5

   END IF
   bArraysInitialized = 1

   LOCAL i AS LONG

   FOR i = 0 TO 11
      glBegin(%GL_LINE_LOOP)
         glNormal3dv(rdod_n(0))
         glVertex3dv(rdod_r(rdod_v(i,0)))
         glVertex3dv(rdod_r(rdod_v(i,1)))
         glVertex3dv(rdod_r(rdod_v(i,2)))
         glVertex3dv(rdod_r(rdod_v(i,3)))
      glEnd
   NEXT

END SUB
' ========================================================================================

' ========================================================================================
' This function draws a wireframe dodecahedron whose facets are rhombic and whose vertices
' are at unit radius. No facet lies normal to any coordinate axes. The polyhedron is
' centered at the origin.
' Adapted from freeglut.
' ========================================================================================
SUB AfxGlutSolidRhombicDodecahedron

   STATIC bArraysInitialized AS LONG

   IF bArraysInitialized = 0 THEN

      DIM rdod_r(13, 2) AS STATIC DOUBLE

      rdod_r( 0, 0) =  0.0            : rdod_r( 0, 1) =  0.0            : rdod_r( 0, 2) =  1.0
      rdod_r( 1, 0) =  0.707106781187 : rdod_r( 1, 1) =  0.000000000000 : rdod_r( 1, 2) =  0.5
      rdod_r( 2, 0) =  0.000000000000 : rdod_r( 2, 1) =  0.707106781187 : rdod_r( 2, 2) =  0.5
      rdod_r( 3, 0) = -0.707106781187 : rdod_r( 3, 1) =  0.000000000000 : rdod_r( 3, 2) =  0.5
      rdod_r( 4, 0) =  0.000000000000 : rdod_r( 4, 1) = -0.707106781187 : rdod_r( 4, 2) =  0.5
      rdod_r( 5, 0) =  0.707106781187 : rdod_r( 5, 1) =  0.707106781187 : rdod_r( 5, 2) =  0.0
      rdod_r( 6, 0) = -0.707106781187 : rdod_r( 6, 1) =  0.707106781187 : rdod_r( 6, 2) =  0.0
      rdod_r( 7, 0) = -0.707106781187 : rdod_r( 7, 1) = -0.707106781187 : rdod_r( 7, 2) =  0.0
      rdod_r( 8, 0) =  0.707106781187 : rdod_r( 8, 1) = -0.707106781187 : rdod_r( 8, 2) =  0.0
      rdod_r( 9, 0) =  0.707106781187 : rdod_r( 9, 1) =  0.000000000000 : rdod_r( 9, 2) = -0.5
      rdod_r(10, 0) =  0.000000000000 : rdod_r(10, 1) =  0.707106781187 : rdod_r(10, 2) = -0.5
      rdod_r(11, 0) = -0.707106781187 : rdod_r(11, 1) =  0.000000000000 : rdod_r(11, 2) = -0.5
      rdod_r(12, 0) =  0.000000000000 : rdod_r(12, 1) = -0.707106781187 : rdod_r(12, 2) = -0.5
      rdod_r(13, 0) =  0.0            : rdod_r(13, 1) =  0.0            : rdod_r(13, 2) = -1.0

      DIM rdod_v(11, 3) AS STATIC DOUBLE

      rdod_v( 0, 0) = 0 : rdod_v( 0, 1) =  1 : rdod_v( 0, 2) =  5 : rdod_v( 0, 3) =  2
      rdod_v( 1, 0) = 0 : rdod_v( 1, 1) =  2 : rdod_v( 1, 2) =  6 : rdod_v( 1, 3) =  3
      rdod_v( 2, 0) = 0 : rdod_v( 2, 1) =  3 : rdod_v( 2, 2) =  7 : rdod_v( 2, 3) =  4
      rdod_v( 3, 0) = 0 : rdod_v( 3, 1) =  4 : rdod_v( 3, 2) =  8 : rdod_v( 3, 3) =  1
      rdod_v( 4, 0) = 5 : rdod_v( 4, 1) = 10 : rdod_v( 4, 2) =  6 : rdod_v( 4, 3) =  2
      rdod_v( 5, 0) = 6 : rdod_v( 5, 1) = 11 : rdod_v( 5, 2) =  7 : rdod_v( 5, 3) =  3
      rdod_v( 6, 0) = 7 : rdod_v( 6, 1) = 12 : rdod_v( 6, 2) =  8 : rdod_v( 6, 3) =  4
      rdod_v( 7, 0) = 8 : rdod_v( 7, 1) =  9 : rdod_v( 7, 2) =  5 : rdod_v( 7, 3) =  1
      rdod_v( 8, 0) = 5 : rdod_v( 8, 1) =  9 : rdod_v( 8, 2) = 13 : rdod_v( 8, 3) = 10
      rdod_v( 9, 0) = 6 : rdod_v( 9, 1) = 10 : rdod_v( 9, 2) = 13 : rdod_v( 9, 3) = 11
      rdod_v(10, 0) = 7 : rdod_v(10, 1) = 11 : rdod_v(10, 2) = 13 : rdod_v(10, 3) = 12
      rdod_v(11, 0) = 8 : rdod_v(11, 1) = 12 : rdod_v(11, 2) = 13 : rdod_v(11, 3) =  9

      DIM rdod_n(11, 2) AS STATIC DOUBLE

      rdod_n( 0, 0) =  0.353553390594 : rdod_n( 0, 1) =  0.353553390594 : rdod_n( 0, 2) =  0.5
      rdod_n( 1, 0) = -0.353553390594 : rdod_n( 1, 1) =  0.353553390594 : rdod_n( 1, 2) =  0.5
      rdod_n( 2, 0) = -0.353553390594 : rdod_n( 2, 1) = -0.353553390594 : rdod_n( 2, 2) =  0.5
      rdod_n( 3, 0) =  0.353553390594 : rdod_n( 3, 1) = -0.353553390594 : rdod_n( 3, 2) =  0.5
      rdod_n( 4, 0) =  0.000000000000 : rdod_n( 4, 1) =  1.000000000000 : rdod_n( 4, 2) =  0.0
      rdod_n( 5, 0) = -1.000000000000 : rdod_n( 5, 1) =  0.000000000000 : rdod_n( 5, 2) =  0.0
      rdod_n( 6, 0) =  0.000000000000 : rdod_n( 6, 1) = -1.000000000000 : rdod_n( 6, 2) =  0.0
      rdod_n( 7, 0) =  1.000000000000 : rdod_n( 7, 1) =  0.000000000000 : rdod_n( 7, 2) =  0.0
      rdod_n( 8, 0) =  0.353553390594 : rdod_n( 8, 1) =  0.353553390594 : rdod_n( 8, 2) = -0.5
      rdod_n( 9, 0) = -0.353553390594 : rdod_n( 9, 1) =  0.353553390594 : rdod_n( 9, 2) = -0.5
      rdod_n(10, 0) = -0.353553390594 : rdod_n(10, 1) = -0.353553390594 : rdod_n(10, 2) = -0.5
      rdod_n(11, 0) =  0.353553390594 : rdod_n(11, 1) = -0.353553390594 : rdod_n(11, 2) = -0.5

   END IF
   bArraysInitialized = 1

   LOCAL i AS LONG

   FOR i = 0 TO 11
      glBegin(%GL_QUADS)
         glNormal3dv(rdod_n(0))
         glVertex3dv(rdod_r(rdod_v(i,0)))
         glVertex3dv(rdod_r(rdod_v(i,1)))
         glVertex3dv(rdod_r(rdod_v(i,2)))
         glVertex3dv(rdod_r(rdod_v(i,3)))
      glEnd
   NEXT

END SUB
' ========================================================================================

