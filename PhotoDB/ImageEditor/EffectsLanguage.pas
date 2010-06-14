unit EffectsLanguage;

interface

//{$DEFINE ENGL}
{$DEFINE RUS}

const
 {$IFDEF RUS}
 EFF_TEXT_MES_GAUSS_BLUR_RADIUS = 'Радиус: [%2.1f]';
 EFF_TEXT_MES_SHARPEN_EFFECT_SIZE = 'Сила эффекта: [%2.1f]';
 EFF_TEXT_MES_GAUSS_BLUR = 'Гауссово размытие';
 TEXT_MES_EX_EFFECTS = 'Эффекты';
 TEXT_MES_PREVIEW = 'Предпросмотр';
 TEXT_MES_SHARPEN = 'Обострение';
 TEXT_MES_PIXEL_EFFECT = 'Пиксели';
 TEXT_MES_WIDTH_F = 'Ширина [%d]';
 TEXT_MES_HEIGHT_F = 'Высота [%d]';
 TEXT_MES_WAVE = 'Волна';
 TEXT_MES_FREQUENCY_F = 'Частота [%d]';
 TEXT_MES_LENGTH_F = 'Длинна [%d]';
 TEXT_MES_WAVE_HORIZONTAL = 'Горизонтально';
 TEXT_MES_BK_COLOR = 'Цвет фона';
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
 TEXT_MES_CUSTOM_GRAYSCALE = 'Произвольное чёрно\белое';
 TEXT_MES_GRAYSCALE_TEXT = 'Цветное - Чёрно\белое [%d]:';
 TEXT_MES_SEPIA_TEXT = 'Значение эффекта [%d]';
 TEXT_MES_CUSTOM_SEPIA = 'Произвольная Sepia';
 TEXT_MES_DISORDER = 'Разброс';
 TEXT_MES_HORIZONTAL_DISORDER = 'Горизонтальный Разброс [%d]';
 TEXT_MES_VERTICAL_DISORDER = 'Вертикальный Разброс [%d]';
 TEXT_MES_COLOR_REPLACER = 'Замена Цвета';
 TEXT_MES_DISORDER_F = 'Разброс [%d]';
 TEXT_MES_DISORDER_SIZE_F = 'Крутизна [%d]';
 TEXT_MES_COLOR_BASE = 'Заменяемый цвет';
 TEXT_MES_COLOR_TO = 'Новый цвет';
 TEXT_MES_SELECT_COLOR = 'Выбрать цвет';
 TEXT_MES_INVERSE = 'Инвертировать';
 TEXT_MES_AUTO_LEVELS = 'АвтоЯркость';
 TEXT_MES_AUTO_COLORS = 'АвтоЦвет';
 TEXT_MES_GRAYSCALE = 'Чёрно\белое';
 TEXT_MES_COLOR_NOISE = 'Цветной шум';
 TEXT_MES_MONO_NOISE = 'Однотональный шум';
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
 TEXT_MES_CUSTOM_USER_EFFECT = 'Произвольный эффект';
 TEXT_MES_MATRIX_5_5 = 'Матрица 5х5';
 TEXT_MES_DEVIDER = 'Делитель';
 TEXT_MES_SAMPLE_M_EFFECT = 'Примеры эффектов';
 TEXT_MES_SAVE_PRESENT = 'Сохранить';
 TEXT_MES_LOAD_PRESENT = 'Загрузить';
 TEXT_MES_DELETE_PRESENT = 'Удалить';
 TEXT_MES_PRESENT_NAME = 'Имя настройки';
 TEXT_MES_FILTER_WORK = 'Работа фильтра "%s"';
 TEXT_MES_TRANSPARENCY = 'Прозрачность';
 TEXT_MES_TRANSPARENCY_F = 'Прозрачность [%s]';
 {$ENDIF}


 {$IFDEF ENGL}
 EFF_TEXT_MES_GAUSS_BLUR_RADIUS = 'Radius: [%2.1f]';
 EFF_TEXT_MES_SHARPEN_EFFECT_SIZE = 'Effect size: [%2.1f]';
 EFF_TEXT_MES_GAUSS_BLUR = 'Gauss blur';
 TEXT_MES_EX_EFFECTS = 'Effects';
 TEXT_MES_PREVIEW = 'Preview';
 TEXT_MES_SHARPEN = 'Sharpen';
 TEXT_MES_PIXEL_EFFECT = 'Pixels';
 TEXT_MES_WIDTH_F = 'Width [%d]';
 TEXT_MES_HEIGHT_F = 'Height [%d]';
 TEXT_MES_WAVE = 'Wave';
 TEXT_MES_FREQUENCY_F = 'Frequency [%d]';
 TEXT_MES_LENGTH_F = 'Length [%d]';
 TEXT_MES_WAVE_HORIZONTAL = 'Horizontal';
 TEXT_MES_BK_COLOR = 'Backgroud color';
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
 TEXT_MES_SEPIA_TEXT = 'Sepia value [%d]';
 TEXT_MES_CUSTOM_SEPIA = 'Custom Sepia';
 TEXT_MES_DISORDER = 'Disorder';
 TEXT_MES_HORIZONTAL_DISORDER = 'Horizontal Disorder [%d]';
 TEXT_MES_VERTICAL_DISORDER = 'Vertical Disorder [%d]';
 TEXT_MES_COLOR_REPLACER = 'Color replacer';
 TEXT_MES_DISORDER_F = 'Disorder [%d]';
 TEXT_MES_DISORDER_SIZE_F = 'Value [%d]';
 TEXT_MES_COLOR_BASE = 'Selected Color';
 TEXT_MES_COLOR_TO = 'New Color';
 TEXT_MES_SELECT_COLOR = 'Select color';
 TEXT_MES_INVERSE = 'Inverse';
 TEXT_MES_AUTO_LEVELS = 'AutoLevels';
 TEXT_MES_AUTO_COLORS = 'AutoColors';
 TEXT_MES_GRAYSCALE = 'Grayscale';
 TEXT_MES_COLOR_NOISE = 'Color noise';
 TEXT_MES_MONO_NOISE = 'Mono noise';
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
 TEXT_MES_CUSTOM_USER_EFFECT = 'Custom Effect';
 TEXT_MES_MATRIX_5_5 = 'Metrix 5x5';
 TEXT_MES_DEVIDER = 'Devider';
 TEXT_MES_SAMPLE_M_EFFECT = 'Sample effect';
 TEXT_MES_SAVE_PRESENT = 'Save presents';
 TEXT_MES_LOAD_PRESENT = 'Load presents';
 TEXT_MES_DELETE_PRESENT = 'Delete presents';
 TEXT_MES_PRESENT_NAME = 'Present name';
 TEXT_MES_FILTER_WORK = 'Filter "%s" working';
 TEXT_MES_TRANSPARENCY = 'Transparency';
 TEXT_MES_TRANSPARENCY_F = 'Transparency [%s]';

 {$ENDIF}

implementation

end.
