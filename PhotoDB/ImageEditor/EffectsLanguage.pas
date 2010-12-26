unit EffectsLanguage;

interface

//{$DEFINE ENGL}
{$DEFINE RUS}

const
 {$IFDEF RUS}
 TEXT_MES_EX_EFFECTS = 'Эффекты';
 TEXT_MES_PREVIEW = 'Предпросмотр';
 TEXT_MES_SHARPEN = 'Обострение';
 TEXT_MES_EYE_COLOR = 'Цвет злаз';
 TEXT_MES_COLOR_GREEN = 'Зелёный';
 TEXT_MES_COLOR_BLUE = 'Синий';
 TEXT_MES_COLOR_BROWN = 'Коричневый';
 TEXT_MES_COLOR_BLACK = 'Чёрный';
 TEXT_MES_COLOR_GRAY = 'Серый';
 TEXT_MES_COLOR_CUSTOM = 'Произвольный...';
 TEXT_MES_SMOOTH_METHOD = 'Улучшенное сглаживание';
 TEXT_MES_BASE_METHOD = 'Базовое сглаживание';
 TEXT_MES_METHOD = 'Метод';
 TEXT_MES_PROPORTIONS = 'Пропорции:';
// TEXT_MES_CUSTOM_GRAYSCALE = 'Произвольное чёрно\белое';
// TEXT_MES_GRAYSCALE_TEXT = 'Цветное - Чёрно\белое [%d]:';
// TEXT_MES_SEPIA_TEXT = 'Значение эффекта [%d]';
// TEXT_MES_CUSTOM_SEPIA = 'Произвольная Sepia';
// TEXT_MES_DISORDER = 'Разброс';
// TEXT_MES_DISORDER_F = 'Разброс [%d]';
// TEXT_MES_INVERSE = 'Инвертировать';
// TEXT_MES_AUTO_LEVELS = 'АвтоЯркость';
// TEXT_MES_AUTO_COLORS = 'АвтоЦвет';
// TEXT_MES_GRAYSCALE = 'Чёрно\белое';
// TEXT_MES_COLOR_NOISE = 'Цветной шум';
// TEXT_MES_MONO_NOISE = 'Однотональный шум';
 TEXT_MES_FISH_EYE = 'Рыбий глаз';
 TEXT_MES_SPLIT_BLUR = 'Линейное размытие';
 TEXT_MES_TWIST = 'Скручивание';
 TEXT_MES_SHARPNESS_SMOOTH_METHOD = 'Сглаживание с sharpness';
 TEXT_MES_DRAW_STYLE_NORMAL = 'Обычное';
 TEXT_MES_DRAW_STYLE_SUM = 'Сумма';
 TEXT_MES_DRAW_STYLE_DARK = 'Тёмное';
 TEXT_MES_DRAW_STYLE_WHITE = 'Светлое';
 TEXT_MES_DRAW_STYLE_COLOR = 'Цвет';
 TEXT_MES_DRAW_STYLE_INV_COLOR = 'Инверсированные цвет';
 TEXT_MES_DRAW_STYLE_CHANGE_COLOR = 'Замена цвета';
 TEXT_MES_DRAW_STYLE_DIFFERENCE = 'Разница';
 TEXT_MES_OPTIMIZE_IMAGE = 'Оптимизировать изображение';
 TEXT_MES_ANTIALIAS = 'Сглаживание';
// TEXT_MES_CUSTOM_USER_EFFECT = 'Произвольный эффект';
 TEXT_MES_FILTER_WORK = 'Работа фильтра "%s"';
 TEXT_MES_TRANSPARENCY = 'Прозрачность';
 TEXT_MES_TRANSPARENCY_F = 'Прозрачность [%s]';
 {$ENDIF}


 {$IFDEF ENGL}
 TEXT_MES_EX_EFFECTS = 'Effects';
 TEXT_MES_PREVIEW = 'Preview';
 TEXT_MES_SHARPEN = 'Sharpen';
 TEXT_MES_EYE_COLOR = 'Eye color';
 TEXT_MES_COLOR_GREEN = 'Green';
 TEXT_MES_COLOR_BLUE = 'Blue';
 TEXT_MES_COLOR_BROWN = 'Brown';
 TEXT_MES_COLOR_BLACK = 'Black';
 TEXT_MES_COLOR_GRAY = 'Gray';
 TEXT_MES_COLOR_CUSTOM = 'Custom...';
 TEXT_MES_SMOOTH_METHOD = 'Smooth';
 TEXT_MES_BASE_METHOD = 'Base resize';
 TEXT_MES_METHOD = 'Method';
 TEXT_MES_PROPORTIONS = 'Proportions:';

 TEXT_MES_CUSTOM_GRAYSCALE = 'Custom grayscale';
 TEXT_MES_GRAYSCALE_TEXT = 'Colored - Grayscale [%d]:';
// TEXT_MES_SEPIA_TEXT = 'Sepia value [%d]';
 TEXT_MES_CUSTOM_SEPIA = 'Custom Sepia';
 TEXT_MES_DISORDER = 'Disorder';
 TEXT_MES_INVERSE = 'Inverse';
 TEXT_MES_AUTO_LEVELS = 'AutoLevels';
 TEXT_MES_AUTO_COLORS = 'AutoColors';
 TEXT_MES_GRAYSCALE = 'Grayscale';
 TEXT_MES_COLOR_NOISE = 'Color noise';
// TEXT_MES_MONO_NOISE = 'Mono noise';
 TEXT_MES_FISH_EYE = 'Fish eye';
 TEXT_MES_SPLIT_BLUR = 'Split blur';
 TEXT_MES_TWIST = 'Twist';
 TEXT_MES_SHARPNESS_SMOOTH_METHOD = 'Resizing with sharpness';

 TEXT_MES_DRAW_STYLE_NORMAL = 'Normal';
 TEXT_MES_DRAW_STYLE_SUM = 'Sum';
 TEXT_MES_DRAW_STYLE_DARK = 'Dark';
 TEXT_MES_DRAW_STYLE_WHITE = 'White';
 TEXT_MES_DRAW_STYLE_COLOR = 'Color';
 TEXT_MES_DRAW_STYLE_INV_COLOR = 'Inverse color';
 TEXT_MES_DRAW_STYLE_CHANGE_COLOR = 'Change color';
 TEXT_MES_DRAW_STYLE_DIFFERENCE = 'Difference';
 TEXT_MES_OPTIMIZE_IMAGE = 'Optimize image';
 TEXT_MES_ANTIALIAS = 'AntiAlias';
// TEXT_MES_CUSTOM_USER_EFFECT = 'Custom Effect';
 TEXT_MES_FILTER_WORK = 'Filter "%s" working';
 TEXT_MES_TRANSPARENCY = 'Transparency';
 TEXT_MES_TRANSPARENCY_F = 'Transparency [%s]';

 {$ENDIF}

implementation

end.
