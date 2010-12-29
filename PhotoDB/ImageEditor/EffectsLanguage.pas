unit EffectsLanguage;

interface

//{$DEFINE ENGL}
{$DEFINE RUS}

const
 {$IFDEF RUS}
 TEXT_MES_EX_EFFECTS = 'Эффекты';
 TEXT_MES_PREVIEW = 'Предпросмотр';
 TEXT_MES_SHARPEN = 'Обострение';

 TEXT_MES_SMOOTH_METHOD = 'Улучшенное сглаживание';
 TEXT_MES_BASE_METHOD = 'Базовое сглаживание';
 TEXT_MES_METHOD = 'Метод';
 TEXT_MES_PROPORTIONS = 'Пропорции:';

 TEXT_MES_FISH_EYE = 'Рыбий глаз';
 TEXT_MES_SPLIT_BLUR = 'Линейное размытие';
 TEXT_MES_TWIST = 'Скручивание';
 TEXT_MES_SHARPNESS_SMOOTH_METHOD = 'Сглаживание с sharpness';

 TEXT_MES_OPTIMIZE_IMAGE = 'Оптимизировать изображение';
 TEXT_MES_ANTIALIAS = 'Сглаживание';
 TEXT_MES_FILTER_WORK = 'Работа фильтра "%s"';
 TEXT_MES_TRANSPARENCY = 'Прозрачность';
 TEXT_MES_TRANSPARENCY_F = 'Прозрачность [%s]';
 {$ENDIF}


 {$IFDEF ENGL}
 TEXT_MES_EX_EFFECTS = 'Effects';
 TEXT_MES_PREVIEW = 'Preview';
 TEXT_MES_SHARPEN = 'Sharpen';

 TEXT_MES_SMOOTH_METHOD = 'Smooth';
 TEXT_MES_BASE_METHOD = 'Base resize';
 TEXT_MES_METHOD = 'Method';
 TEXT_MES_PROPORTIONS = 'Proportions:';

 TEXT_MES_CUSTOM_GRAYSCALE = 'Custom grayscale';
 TEXT_MES_GRAYSCALE_TEXT = 'Colored - Grayscale [%d]:';
 TEXT_MES_SHARPNESS_SMOOTH_METHOD = 'Resizing with sharpness';

 TEXT_MES_OPTIMIZE_IMAGE = 'Optimize image';
 TEXT_MES_ANTIALIAS = 'AntiAlias';
// TEXT_MES_CUSTOM_USER_EFFECT = 'Custom Effect';
 TEXT_MES_FILTER_WORK = 'Filter "%s" working';
 TEXT_MES_TRANSPARENCY = 'Transparency';
 TEXT_MES_TRANSPARENCY_F = 'Transparency [%s]';

 {$ENDIF}

implementation

end.
