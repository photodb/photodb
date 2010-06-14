unit Language;
                                                                          
interface                                                                 

{$DESCRIPTION 'Photo DB v2.2 (Русская версия)'}

Const

 ProgramMail = 'illusdolphin@gmail.com';
 TEXT_MES_PRODUCT_VERSION = '2.2';
 TEXT_MES_WARNING = 'Внимание';
 
 TEXT_MES_UNKNOWN_ERROR_F = 'Непредвиденная ошибка! %s';
 TEXT_MES_CONFIRM = 'Подтверждение';
 TEXT_MES_INFORMATION = 'Информация';
 TEXT_MES_SETUP = 'Установка';        
 TEXT_MES_QUESTION = 'Вопрос';
 TEXT_MES_FILE_EXISTS_NO_ACTION = 'Файл с таким именем уже существует! Выберите другое имя файла.';
 TEXT_MES_FILE_EXISTS = 'Файл с таким именем уже существует! Заменить?';
 TEXT_MES_FILE_EXISTS_1 = 'Файл %s уже существует!'+#13+'Заменить?';
 TEXT_MES_KEY_SAVE = 'Ключ для активации сохранён! Перезапустите приложение для результата!';
 TEXT_MES_DEL_USER_CONFIRM = 'Вы действительно хотите удалить этого пользователя?'+#13+'Пользователь = "%s"';
 TEXT_MES_ADD_DRIVE = 'Вы действительно хотите добавить диск и все подпапки?';
 TEXT_MES_DIR_NOT_FOUND = 'Невозможно найти директорию:'+#13+'%s';
 TEXT_MES_DB_FILE_NOT_VALID = 'Данный файл не является корректным файлом PhotoDB!';
 TEXT_MES_QUIT_SETUP = 'Вы действительно хотите выйти из установки?';
 TEXT_MES_PROG_IS_NEW = 'На компьютер уже установлена более новая версия программы!'+#13+'Вы хотите продолжать?';
 TEXT_MES_PROG_IS = 'На компьютер уже установлена эта программа!'+#13+'Вы хотите продолжать?';
 TEXT_MES_DIR_CR_FAILED = 'Невозможно создать директорию'+#13+'%s'+#13+'Пожалуйста, выберите другую директорию';
 TEXT_MES_SETUP_EXIT = TEXT_MES_QUIT_SETUP;
 TEXT_MES_WAIT_FOR_A_MINUTE = 'Пожалуйста, подождите минуту...';
 TEXT_MES_READING_DB = 'Чтение базы данных...';
 TEXT_MES_READING_GROUPS_DB = 'Чтение базы данных групп';
 TEXT_MES_FILE_NOT_FOUND = 'Файл не найдён!';
 TEXT_MES_INST_BDE = 'Установка DBE...';
 TEXT_MES_WAIT_MIN = TEXT_MES_WAIT_FOR_A_MINUTE ;
 TEXT_MES_QUERY_EX = 'Запрос выполняется... ';
 
 TEXT_MES_SEARCH = 'Поиск';
 TEXT_MES_DONE = 'Выполнено';
 TEXT_MES_STOPING = 'Остановка';
 TEXT_MES_WAITING = 'Ожидание';
 
 TEXT_MES_RESULT = 'Результат';
 TEXT_MES_IDENT = 'Номер';
 TEXT_MES_SEARCH_TEXT = 'Текст поиска';
 TEXT_MES_CALCULATING = 'Вычисление';
 TEXT_MES_INITIALIZE = 'Инициализация';
 TEXT_MES_INITIALIZATION = 'Инициализация';
 TEXT_MES_SIZE = 'Размер';
 TEXT_MES_ITEM = 'Элемент';
 TEXT_MES_ITEMS = 'Элементы';
 TEXT_MES_ADMIN = 'Administrator';   //НЕ ПЕРЕИМЕНОВЫВАТЬ!
 TEXT_MES_NO_RES = 'Нет результатов';
 
 TEXT_MES_GUEST = 'Гость';                                                                                        
 TEXT_MES_MANAGEA = '<Управление>';
 TEXT_MES_GROUPSA = '<Группы>';
 
 TEXT_MES_ID = 'ID';
 TEXT_MES_GENERATING = ' Работа... ';
 TEXT_MES_RATING = 'Оценка';
 TEXT_MES_COMMENT = 'Комментарий';
 TEXT_MES_NAME = 'Имя';
 TEXT_MES_FULL_PATH = 'Полное имя';
 TEXT_MES_COMMENTS = 'Комментарии';
 TEXT_MES_KEYWORDS = 'Ключевые слова';
 TEXT_MES_OWNER = 'Владелец';
 TEXT_MES_DATE = 'Дата';
 TEXT_MES_WIDTH = 'Ширина';
 TEXT_MES_HEIGHT = 'Высота';
 TEXT_MES_COLLECTION = 'Коллекция';
 TEXT_MES_VAL_NOT_SETS = '<Значение не установлено>';
 TEXT_MES_DATE_NOT_EXISTS = '<Даты нет>';
 TEXT_MES_VAR_COM = '<Различные комментарии>';
 TEXT_MES_PROGRESS_PR = 'Выполнение... (&%%)';
 TEXT_MES_LOAD_QUERY_PR = 'Загрузка запроса... (&%%)';
 TEXT_MES_RES_REC = 'Результат = %s записей';
 TEXT_MES_SEARCH_FOR_REC = 'Выполняется поиск...';
 TEXT_MES_SEARCH_FOR_REC_FROM = 'Всего %s записей...';
 TEXT_MES_1 = 'Вы действительно хотите создать новую группу и использовать её для импорта?';
 TEXT_MES_2 = 'Некоторые нити не отвечают...'+#13+'Выполнить принудительное выключение?';
 TEXT_MES_3 = 'Ошибка в SQL запросе. Query:'+#13;
 TEXT_MES_4 = 'Пожалуйста, закройте открытую версию программы и попытайтесь снова';
 TEXT_MES_SERCH_PR = 'Пожалуйста, подождите пока выполняется поиск...';
 TEXT_MES_UNABLE_FIND_IMAGE = 'Невозможно найти данное изображение!';
 TEXT_MES_SLIDE_SHOW = 'Просмотр';
 TEXT_MES_SELECT_ALL = 'Выделить всё';
 TEXT_MES_SHOW_UPDATER = 'Показать Окно обновления';
 TEXT_MES_HELP = 'Справка';
 TEXT_MES_MANAGE_DB = 'Управление БД';
 TEXT_MES_OPTIONS = 'Настройки';
 TEXT_MES_SAVE_AS_TABLE = 'Сохранить как таблицу';
 TEXT_MES_LOAD_RES = 'Загрузить результаты';
 TEXT_MES_SAVE_RES = 'Сохранить результаты';
 TEXT_MES_NEW_PANEL = 'Новая панель';
 TEXT_MES_EXPLORER = 'Проводник';
 TEXT_MES_FIND_TARGET = 'Найти';
 TEXT_MES_GENERAL = 'Общие';
 TEXT_MES_DO_SEARCH_NOW = 'Найти...';
 TEXT_MES_PANELS = 'Панели';
 TEXT_MES_PROPERTIES = 'Свойства';
 TEXT_MES_PROPERTY = 'Свойства';
 TEXT_MES_DATE_NOT_EX = 'Даты нет';
 TEXT_MES_DATE_EX = 'Дата присутствует';
 TEXT_MES_DATE_NOT_SETS = 'Дата не установлена';
 TEXT_MES_EDIT_GROUPS = 'Редактировать группы';
 TEXT_MES_GROUPS_MANAGER = 'Управление группами';
 TEXT_MES_RATING_NOT_SETS = 'Оценка не установлена';
 TEXT_MES_SET_COM = 'Установить комментарий';
 TEXT_MES_SET_COM_NOT = 'Комментарий не установлен';
 TEXT_MES_CUT = 'Вырезать';
 TEXT_MES_COPY_ITEM = 'Копировать элемент';
 
 TEXT_MES_PASTE = 'Вставить';
 TEXT_MES_UNDO = 'Обратно';
 TEXT_MES_SET_VALUE = 'Установить значение';
 TEXT_MES_NOT_AVALIABLE = 'Не доступно';
 TEXT_MES_ADD_FILE = 'Добавить файл';
 TEXT_MES_SHELL = 'Выполнить';
 
 TEXT_MES_CLEAR = 'Очистить';
 TEXT_MES_CLOSE = 'Закрыть';
 TEXT_MES_LOAD_FROM_FILE = 'Загрузить из файла';
 TEXT_MES_SAVE_TO_FILE = 'Сохранить в файл';
 TEXT_MES_DBITEM = 'Пункт в БД';
 TEXT_MES_SEARCH_FOR_IT = 'Найти';
 TEXT_MES_COLOR_THEME = 'Цветовая тема';
 TEXT_MES_MAIN_COLOR = 'Главный цвет';
 TEXT_MES_MAIN_F_COLOR = 'Главный цвет шрифта';
 TEXT_MES_LIST_COLOR = 'Цвет списков';
 TEXT_MES_LIST_F_COLOR = 'Цвет шрифта списков';
 TEXT_MES_EDIT_COLOR = 'Цвет полей редактирования';
 TEXT_MES_EDIT_F_COLOR = 'Цвет шрифта полей редактирования';
 TEXT_MES_LABEL_COLOR = 'Цвет надписей';
 TEXT_MES_LOAD_THEME = 'Загрузить тему';
 TEXT_MES_RESET = 'Сброс';
 TEXT_MES_SAVE_THEME_TO_FILE = 'Сохранить текущую тему в файл';
 TEXT_MES_SHOW_PREVIEW = 'Показывать предпросмотр';
 TEXT_MES_HINTS = 'Предпросмотр';
 TEXT_MES_ANIMATE_SHOW = 'Анимированный показ';
 TEXT_MES_SHOW_SHADOW = 'Показ тени';
 TEXT_MES_USERS = 'Пользователи';
 TEXT_MES_OK = 'Да';
 TEXT_MES_CANCEL = 'Отмена';
 TEXT_MES_SHELL_EXTS = 'Расширения:';
 TEXT_MES_SHOW_CURRENT_OBJ = 'Показывать текущие объекты:';
 TEXT_MES_FOLDERS = 'Папки';
 TEXT_MES_SIMPLE_FILES = 'Простые фалы';
 TEXT_MES_IMAGE_FILES = 'Изображения';
 TEXT_MES_HIDDEN_FILES = 'Скрытые файлы';
 TEXT_MES_TH_OPTIONS = 'Опции предпросмотров:';
 TEXT_MES_SHOW_ATTR = 'Показывать атрибуты';
 TEXT_MES_SHOW_TH_FOLDRS = 'Показывать предпросмотр для папок';
 TEXT_MES_SAVE_TH_FOLDRS = 'Сохранять предпросмотр для папок';
 TEXT_MES_SHOW_TH_IMAGE = 'Показывать предпросмотр для изображений';
 TEXT_MES_VAR_WIDTH = 'Различная ширина';
 TEXT_MES_VAR_HEIGHT = 'Различная высота';
 TEXT_MES_ALL_IN = 'Все в %s';
 TEXT_MES_VAR_LOCATION = '<Различное размещение>';
 TEXT_MES_VAR_FILES = '<Различные файлы>';
 TEXT_MES_ALL_PX = 'Все - %spx.';
 TEXT_MES_SELECTED_ITEMS = 'Выбрано %s элементов';
 TEXT_MES_CLEANING_ITEM = 'Очистка... [%s]';
 TEXT_MES_CLEANING_STOPED = 'Очистка остановлена';
 TEXT_MES_LOG_ON_CAPTION = 'Вход';
 TEXT_MES_LOG_ON = 'Войти!';
 TEXT_MES_AUTO_LOG_ON = 'Авто вход';
 TEXT_MES_CH_USER = 'Изменить пользователя';
 TEXT_MES_ADD_NEW_USER = 'Добавить нового пользователя';
 TEXT_MES_DEL_USER = 'Удалить пользователя';
 TEXT_MES_CANCEL_AS_DEF = 'Убрать "по умолчанию"';
 TEXT_MES_PANEL_CAPTION = 'Панель (%s)';
 TEXT_MES_QUICK_INFO = 'Инф.';
 TEXT_MES_CANT_LOAD_IMAGE = 'Невозможно загрузить изображение из файла:'+#13+'%s';
 TEXT_MES_MY_COMPUTER = 'Мой Компьютер';
 TEXT_MES_VIEW_WITH_DB = 'Показать с помощью PhotoDB';
 TEXT_MES_BROWSE_WITH_DB = 'Проводник с помощью PhotoDB';
 TEXT_MES_ERROR_KERNEL_DLL = 'Невозможно загрузить библиотеку "kernel.dll"';
 TEXT_MES_PIXEL_FORMAT = '%spx.';                                            
 TEXT_MES_PIXEL_FORMAT_D = '%dpx.';
 TEXT_MES_BYTES = 'Бит';
 TEXT_MES_KB = 'Кб';
 TEXT_MES_MB = 'Мб';
 TEXT_MES_GB = 'Гб';
 TEXT_MES_ERROR_LOGON = 'Ошибка входа! (Обратитесь к справке программы за помощью (FAQ)';
 TEXT_MES_ERROR_USER_NOT_FOUND = 'Пользователь не найден!';
 TEXT_MES_ERROR_TABLE_NOT_FOUND = 'База пользователей не найдена! (Обратитесь к справке программы за помощью (FAQ))';
 TEXT_MES_ERROR_USER_ALREADY_EXISTS = 'Пользователь уже существует!!!';
 TEXT_MES_ERROR_PASSWORD_WRONG = 'Пароль неверен!';
 TEXT_MES_CREATING = 'Создание';
 TEXT_MES_UNABLE_SHOW_FILE = 'Невозможно отобразить файл:';
 TEXT_MES_NO_DB_FILE = '<нет файла>';
 TEXT_MES_OPEN = 'Открыть';
 TEXT_MES_CREATE_NEW = 'Создать новую';
 TEXT_MES_FIND = 'Найти';
 TEXT_MES_EXIT = 'Выход';
 TEXT_MES_USE_AS_DEFAULT_DB = 'Использовать БД по умолчанию';
 TEXT_MES_SELECT_DATABASE = 'Выбрать БД';
 TEXT_MES_SIZE_FORMAT = 'Размер : %s';
 TEXT_MES_SIZE_FORMATA = 'Размер = %s';
 TEXT_MES_NEW_DB_SIZE_FORMAT = 'Размер новой базы (ориентировочно) = %s';  
 TEXT_MES_NEW_DB_SIZE_FORMAT_10000 = 'Размер новой базы (ориентировочно для 10000 записей) = %s';
 TEXT_MES_RATING_FORMATA = 'Оценка = %s';
 TEXT_MES_ID_FORMATA = 'ID = %s';
 TEXT_MES_DIMENSIONS = 'Разрешение : %s x %s';
 TEXT_MES_ADD_USER_CAPTION = 'Добавить пользователя';
 TEXT_MES_PASSWORD = 'Пароль';
 TEXT_MES_NEW_PASSWORD = 'Новый пароль';
 TEXT_MES_CH_USER_CAPTION = 'Изменить пользователя';
 TEXT_MES_CREATE_ADMIN_CAPTION = 'Создание Администратора';
 TEXT_MES_UPDATING_REC_FORMAT = 'Запись №%s [%s]';
 TEXT_MES_PAUSED = 'Пауза...';
 TEXT_MES_DEL_FROM_DB = 'Удалить информацию из БД';
 TEXT_MES_DEL_FILE = 'Удалить файл';
 TEXT_MES_REFRESH_ITEM = 'Обновить';
 TEXT_MES_RENAME = 'Переименовать';
 TEXT_MES_ROTATE_90 = '90* ЧС';
 TEXT_MES_ROTATE_180 = '180*';
 TEXT_MES_ROTATE_270 = '90* ПЧС';
 TEXT_MES_ROTATE_0 = 'Нет';
 TEXT_MES_ROTATE = 'Поворот';
 TEXT_MES_PRIVATE = 'Сделать личной';
 TEXT_MES_COMMON = 'Сделать общей';
 TEXT_MES_SHOW_FOLDER = 'Показать папку';
 TEXT_MES_SEND_TO = 'Отправить в';
 TEXT_MES_EDITA = '<Редактировать>';
 TEXT_MES_DEL_FROM_DB_CONFIRM = 'Вы действительно хотите удалить эту информацию из БД?';
 TEXT_MES_DEL_FILE_CONFIRM = 'Это физическое удаление файла! Продолжать?';
 TEXT_MES_SHELL_OPEN_CONFIRM_FORMAT = 'Вы выбрали %s объектов.'+#13+'Продолжение может повлечь за собой медленную работу компьютера!'+#13+' Продолжать?';
 TEXT_MES_PROGRAM_CODE = 'Код вашей копии программы:';
 TEXT_MES_ACTIVATION_NAME = 'Имя для активации:';
 TEXT_MES_ACTIVATION_KEY = 'Введите сюда ключ для активации:';
 TEXT_MES_SET_CODE = 'Установить код';
 TEXT_MES_ACTIVATION_CAPTION = 'Активация';
 TEXT_MES_CLOSE_FORMAT = 'Закрыть [%s]';
 TEXT_MES_REG_TO = 'Зарегистрировано на:';
 TEXT_MES_COPY_NOT_ACTIVATED = '<Копия не активирована>';
 TEXT_MES_ADD_DISK = 'Добавить диск';
 TEXT_MES_ADD_DIRECTORY = 'Добавить директорию';
 TEXT_MES_ADDFILE = 'Добавить файл';
 TEXT_MES_MANY_FILES = 'Много файлов';
 TEXT_MES_FILES = 'Файлы';
 TEXT_MES_NEW_FOLDER = 'Новая папка';
 TEXT_MES_REC_PRIVATE = 'Запись личная';
 TEXT_MES_SEL_PLACE_TO_COPY_ONE = 'Выберите место, куда Вы хотите скопировать "%s". Затем нажмите кнопку "Да"';
 TEXT_MES_SEL_PLACE_TO_COPY_MANY = 'Выберите место, куда Вы хотите скопировать эти %s объекта. Затем нажмите кнопку "Да"';
 TEXT_MES_SEL_PLACE_TO_MOVE_ONE = 'Выберите место, куда Вы хотите переместить "%s". Затем нажмите кнопку "Да"';
 TEXT_MES_SEL_PLACE_TO_MOVE_MANY = 'Выберите место, куда Вы хотите переместить эти %s items. Затем нажмите кнопку "Да"';
 TEXT_MES_IMAGE_PRIVIEW = 'Предпросмотр:';
 TEXT_MES_DELETE = 'Удалить';
 TEXT_MES_COPY_TO = 'Скопировать в ';
 TEXT_MES_MOVE_TO = 'Переместить в ';
 TEXT_MES_TASKS = 'Задачи';
 TEXT_MES_NEW_WINDOW = 'Новое окно';
 
 TEXT_MES_DIRECTORY = 'Директория';
 
 TEXT_MES_OPEN_IN_NEW_WINDOW = 'Открыть в новом окне';
 TEXT_MES_ADD_FOLDER = 'Добавить папку';
 TEXT_MES_MAKE_NEW_FOLDER = 'Каталог';
 TEXT_MES_OPEN_IN_SEARCH_WINDOW = 'Открыть в окне поиска';
 TEXT_MES_GO_TO_SEARCH_WINDOW = 'Перейти в окно поиска';
 TEXT_MES_FILE = 'Файл';
 TEXT_MES_FILE_NAME = 'Имя файла';
 TEXT_MES_ACCESS = 'Доступ';

 TEXT_MES_BACK = 'Назад';
 TEXT_MES_NEXT = 'Следующий';
 TEXT_MES_FORWARD = 'Вперёд';
 TEXT_MES_UP = 'Вверх';
 TEXT_MES_VIEW = 'Вид';
 TEXT_MES_SHOW_EXPLORER_PANEL = 'Показать панель проводника';
 TEXT_MES_SHOW_INFO_PANEL = 'Показать панель с информацией';
 TEXT_MES_SHOW_FOLDERS = 'Показывать папки';
 TEXT_MES_SHOW_FILES = 'Показывать файлы';
 TEXT_MES_SHOW_HIDDEN = 'Показывать скрытые';
 TEXT_MES_SHOW_ONLY_COMMON = 'Показывать только общие';
 TEXT_MES_SHOW_PRIVATE = 'Показывать личные';
 TEXT_MES_TOOLS = 'Модули';
 TEXT_MES_SHOW_DB_MANAGER = 'Управление БД';
 TEXT_MES_SEARCHING = 'Поиск';
 TEXT_MES_CONNECTING_TO_DB = 'Соединение с БД...';
 TEXT_MES_GETTING_INFO_FROM_DB = 'Получение информации из БД...';
 TEXT_MES_READING_FOLDER = 'Чтение папки...';
 TEXT_MES_LOADING_INFO = 'Загрузка информации...';
 TEXT_MES_LOADING_FOLDERS = 'Загрузка папок...';
 TEXT_MES_LOADING_IMAGES = 'Загрузка изображений...';
 TEXT_MES_LOADING_FILES = 'Загрузка файлов...';
 TEXT_MES_LOADING_TH = 'Загрузка предпросмотров';
 TEXT_MES_LOADING_TH_FOR_IMAGES = 'Загрузка предпросмотра для изображений...';
 TEXT_MES_LOADING_TH_FOR_FOLDERS = 'Загрузка предпросмотра для папок...';
 TEXT_MES_READING_MY_COMPUTER = 'Чтение содержимого Моего Компьютера...';
 TEXT_MES_NO_FILE = '<нет файла>';
 TEXT_MES_SEL_FOLDER_DB_FILES = 'Выберите папку к файлам БД';
 TEXT_MES_SEL_FOLDER_INSTALL = 'Выберите установочную директорию ';
 TEXT_MES_ENTER_NAME = 'Введите ваше имя';
 TEXT_MES_NAMEA = '<имя>';
 TEXT_MES_SUPPORTED_TYPES = 'Поддерживаемые типы файлов:';
 TEXT_MES_SUPPORTED_TYPES_CHECKED = '- Файл будет открываться с помощью PhotoDB';
 TEXT_MES_SUPPORTED_TYPES_GRAYED = '- Будет добавлен пункт для запуска';
 TEXT_MES_SUPPORTED_TYPES_UNCHECKED = '- Расширение не регистрируется';
 TEXT_MES_TO_INSTALL = 'Нажмите кнопку "Установить" для начала установки';
 TEXT_MES_CHECK_ALL = 'Выбрать всё';
 TEXT_MES_UNCHECK_ALL = 'Отменить все';
 TEXT_MES_DEFAULT = 'По умолчанию';
 TEXT_MES_EXIT_SETUP = 'Выход';
 TEXT_MES_INSTALL = 'Установить';
 TEXT_MES_INSTALL_CAPTION = 'Установка';
 TEXT_MES_I_ACCEPT = 'Я согласен с этими аргументами';
 TEXT_MES_END_FOLDER = 'Конечная папка программы';
 TEXT_MES_END_DB_FOLDER = 'Папка с файлами базы данных';
 TEXT_MES_DEF_DB = 'База данных по умолчанию';
 TEXT_MES_MOVE_PRIVATE = 'Перемещать личные записи';
 TEXT_MES_EXIS_SETUP = 'Выход из установки';
 TEXT_MES_IDAPI_NEED = 'ОШИБКА: Borland Database Engine (BDE) не найдена!' + #13+ 'BDE необходима для работы программы, будет выполнена её установка...';
 TEXT_MES_IDAPI_NOT_FOUND = 'ОШИБКА: Borland Database Engine (BDE) не найдена!' + #13+'Установка не может продолжаться дальше без данного компонента....';
 TEXT_MES_COPYING_NEW_FILES = 'Копирование новых файлов';
 TEXT_MES_CURRENT_FILE = 'Текущий файл';
 TEXT_MES_COPYING_PR = 'Копирование... (&%%)';
 TEXT_MES_REGISTRY_ENTRIES = 'Ключи реестра...';
 TEXT_MES_WAIT = 'Пожалуйста, подождите... ';
 TEXT_MES_CREATING_CHORTCUTS = 'Создание ярлыков...';
 TEXT_MES_DISCRIPTION = 'Содержит ваши фотографии';
 TEXT_MES_DB_EXISTS_ADD_NEW = 'Конечная БД уже существует!'+#13+'Хотите ли Вы добавить в неё записи?';
 TEXT_MES_CANT_CREATE_END_DB = 'Невозможно создать файл БД!';
 TEXT_MES_MOVING_DB = 'Перемещение БД';
 TEXT_MES_CURRENT_REC = 'Текущая запись';
 TEXT_MES_ADDING_INSTALL_FORMAT = 'Запись %s из %s  [%s]';
 TEXT_MES_DELETING_FILES = 'Удаление файлов';
 TEXT_MES_DELETING_DB_FILES = 'Удаления файлов БД';
 TEXT_MES_DELETING_PR = 'Удаление... (&%%)';
 TEXT_MES_WAIT_PR = 'Пожалуйста, ждите... (&%%)';
 TEXT_MES_DELETING_REG_ENTRIES = 'Удаление записей в реестре...';
 TEXT_MES_DELETING_CHORTCUTS = 'Удаление ярлыков...';
 TEXT_MES_DELETING_TEMP_FILES = 'Удаление временных файлов...';
 TEXT_MES_CLOSE_OPENED_PROGRAM = 'Пожалуйста, закройте открытую программу и попытайтесь снова';
 TEXT_MES_UNINSTALL = 'Удаление';
 TEXT_MES_UNINSTALL_CAPTION = 'Удаление программы';
 TEXT_MES_UNINSTALL_LIST = 'Компоненты';
 TEXT_MES_PROGRAM_FILES = 'Файлы программы';
 TEXT_MES_DB_FILES = 'Файлы БД';
 TEXT_MES_REG_ENTRIES = 'Записи в реестре';
 TEXT_MES_CHORTCUTS = 'Ярлыки';
 TEXT_MES_ADDING_FILE_PR = 'Добавление файлов... (&%%)';
 TEXT_MES_NOW_FILE = '<текущий файл>';
 TEXT_MES_NO_FILE_TO_ADD = 'Нет файлов для добавления';
 TEXT_MES_LAST_FILE = 'Последний файл...';
 TEXT_MES_PAUSE = 'Пауза';
 TEXT_MES_UNPAUSE = 'Запустить';
 TEXT_MES_NO_ANY_FILEA = '<Нет файлов>';
 TEXT_MES_BREAK_BUTTON = 'Прервать!';
 TEXT_MES_STAY_ON_TOP = 'Оставаться поверх окон';
 TEXT_MES_LAYERED = 'Прозрачность';
 TEXT_MES_HIDE = 'Спрятать';
 TEXT_MES_FILL = 'Нет';
 TEXT_MES_AUTO = 'Автоматически';
 TEXT_MES_AUTO_ANSWER = 'Автоответ';
 TEXT_MES_NONE = 'Нет';
 TEXT_MES_REPLACE_ALL = 'Заменять все';
 TEXT_MES_ADD_ALL = 'Добавить все';
 TEXT_MES_SKIP_ALL = 'Пропустить все';
 TEXT_MES_ASK_ABOUT_DUBLICATES = 'Сообщать о дубликатах';
 TEXT_MES_NEEDS_ACTIVATION = 'Необходима активизация программы';
 TEXT_MES_LIMIT_RECS = 'Вы работаете в неактивированной БД!'+#13+'Вы можете добавить только %s записей!'+#13+'Выберите "Справка" в меню в окне поиска"';
 TEXT_MES_LIMIT_TIME_END = 'Время работы программы истекло! Вы должны активизировать данную копию!';
 TEXT_MES_ALIAS_NOT_FOUND_CREATE = 'Алиас %s не найден!'+#13+'хотите ли Вы его создать?';
 TEXT_MES_ALIAS_NOT_FOUND = 'Алиас не найден';
 TEXT_MES_CANT_CREATE_ALIAS = 'Алиас не найден!'+#13+'Программа будет закрыта';
 TEXT_MES_UNABLE_TO_SAVE_CONFIG_FILE = 'Невозможно сохранить файл настроек!';
 TEXT_MES_PACKING_QUESTION = 'Вы действительно хотите упаковать таблицу?'+#13+'Упаковка начнётся при следующем запуске программы...';
 TEXT_MES_EXPORT_QUESTION = 'Вы действительно хотите экспортировать таблицу?';
 TEXT_MES_IMPORT_QUESTION = 'Вы действительно хотите импортировать таблицу?';
 TEXT_MES_BACK_UP_QUESTION = 'Вы действительно хотите создать резервную копию?';
 TEXT_MES_DB_OPTIONS = 'Настройки БД';
 TEXT_MES_PACK_TABLE = 'Упаковать БД';
 TEXT_MES_EXPORT_TABLE = 'Экспортировать';
 TEXT_MES_IMPORT_TABLE = 'Импортировать';
 TEXT_MES_BACK_UP_DB = 'Резервная копия';
 TEXT_MES_CLEANING = 'Очистка';
 TEXT_MES_WHERE = 'Где';
 TEXT_MES_EXES_SQL = 'Выполнить SQL';
 TEXT_MES_SELECTED_INFO = 'Информация:';
 TEXT_MES_FIELD = 'Поле';
 TEXT_MES_CURRENT_DATABASE = 'Текущая БД';
 TEXT_MES_FILEA = '<файл>';
 TEXT_MES_NO_FILEA = '<нет файла>';
 TEXT_MES_DB_FILE_MANAGER = 'Изменение файла БД';
 TEXT_MES_GO_TO_REC_ID = 'Перейти к записи с ID';
 TEXT_MES_MANAGER_DB_CAPTION = 'Управление БД';
 TEXT_MES_PACKING_MAIN_DB_FILE = 'Упаковка файлов БД...';
 TEXT_MES_PACKING_GROUPS_DB_FILE = 'Упаковка файла с группами...';
 TEXT_MES_PACKING_END = 'Упаковка закончена...';
 TEXT_MES_WELCOME_FORMAT = 'Добро пожаловать в %s!';
 TEXT_MES_PACKING_BEGIN = 'Упаковка началась...';
 TEXT_MES_PACKING_TABLE = 'Упаковка таблицы:';
 TEXT_MES_CMD_CAPTION = 'Окно команд';
 TEXT_MES_CMD_TEXT = 'Подождите пока программа выполнит операцию...';
 TEXT_MES_EXPORT_WINDOW_CAPTION = 'Экспорт таблицы';
 TEXT_MES_EXPORT_PRIVATE = 'Экспорт личных записей';
 TEXT_MES_EXPORT_ONLY_RATING = 'Экспорт только записей с оценкой';
 TEXT_MES_EXPORT_REC_WITHOUT_FILES = 'Экспорт записей без файлов';
 TEXT_MES_EXPORT_GROUPS = 'Экспортировать группы';
 TEXT_MES_BEGIN_EXPORT = 'Начать экспорт';
 TEXT_MES_REC = 'Запись';
 TEXT_MES_REC_FROM_RECS_FORMAT = 'Запись #%s из %s';
 TEXT_MES_CLEANING_CAPTION = 'Очистка';
 TEXT_MES_DELETE_NOT_VALID_RECS = 'Удалять ненужные записи';
 TEXT_MES_VERIFY_DUBLICATES = 'Проверять дубликаты';
 TEXT_MES_MARK_DELETED_FILES = 'Помечать удалённые файлы';
 TEXT_MES_ALLOW_AUTO_CLEANING = 'Позволить автоочистку';
 TEXT_MES_STOP_NOW = 'Остановить';
 TEXT_MES_START_NOW = 'Начать';
 TEXT_MES_IMPORTING_CAPTION = 'Импорт БД';
 TEXT_MES_RECS_ADDED = 'Записей добавлено:';
 TEXT_MES_RECS_UPDATED = 'Записей обновлено:';
 TEXT_MES_RECS_ADDED_PR = '&%% (Добавлено)';
 TEXT_MES_RECS_UPDATED_PR = '&%% (Обновлено)';
 TEXT_MES_STATUS = 'Статус';
 TEXT_MES_STATUSA = '<Статус>';
 TEXT_MES_CURRENT_ACTION = 'Текущее действие';
 TEXT_MES_ACTIONA = '<Действие';
 TEXT_MES_MAIN_DB_AND_ADD_SAME = 'Главная и добавочная БД совпадают!';
 TEXT_MES_MAIN_DB_RECS_FORMAT = 'Главная БД (%s Rec)';
 TEXT_MES_ADD_DB_RECS_FORMAT = 'Добавочная БД (%s Rec)';
 TEXT_MES_RES_DB_RECS_FORMAT = 'Результирующая БД (%s Rec)';
 TEXT_MES_ADD_NEW_RECS = 'Добавлять новые записи';
 TEXT_MES_ADD_REC_WITHOUT_FILES = 'Добавлять записи без файлов';
 TEXT_MES_ADD_RATING = 'Добавлять оценку';
 TEXT_MES_ADD_ROTATE = 'Добавлять поворот';
 TEXT_MES_ADD_PRIVATE = 'Добавлять личные';
 TEXT_MES_ADD_KEYWORDS = 'Добавлять ключевые слова';
 TEXT_MES_ADD_GROUPS = 'Добавлять группы';
 TEXT_MES_ADD_NIL_COMMENT = 'Добавлять пустые комментарии';
 TEXT_MES_ADD_COMMENT = 'Добавлять комментарии';
 TEXT_MES_ADD_NAMED_COMMENT = 'Добавлять именованые комментарии';
 TEXT_MES_ADD_DATE = 'Добавлять дату';
 TEXT_MES_ADD_LINKS = 'Добавлять ссылки';
 TEXT_MES_IGNORE_KEYWORDS = 'Игнорировать слова';
 TEXT_MES_IMPORTING_OPTIONS_CAPTION = 'Настройки импорта';
 TEXT_MES_REPLACE_GROUP_BOX = 'Заменить';
 TEXT_MES_ON__REPLACE_ = 'на';
 TEXT_MES_USE_CURRENT_DB = 'Использовать текущую БД';
 TEXT_MES_USE_ANOTHER_DB = 'Использовать другую БД';
 TEXT_MES_MAIN_DB = 'Главная БД';
 TEXT_MES_ADD_DB = 'Добавочная БД';
 TEXT_MES_RES_DB = 'Результирующая БД';
 TEXT_MES_BY_AUTHOR = 'Автор';
 TEXT_MES_LIST_IGNORE_WORDS = 'Список игнорируемых слов:';
 TEXT_MES_EDIT_GROUPS_CAPTION = 'Редактировать группы';
 TEXT_MES_GROUP_MANAGER_BUTTON = 'Управление';
 TEXT_MES_NEW_GROUP_BUTTON = 'Новая группа';
 TEXT_MES_AVALIABLE_GROUPS = 'Доступные группы:';
 TEXT_MES_CURRENT_GROUPS = 'Текущие группы:';
 TEXT_MES_DELETE_ITEM = 'Удалить';
 TEXT_MES_GREATE_GROUP = 'Создание группы';
 TEXT_MES_CHANGE_GROUP = 'Изменение группы';
 TEXT_MES_CREATE_GROUP_CAPTION = 'Создание новой группы';
 TEXT_MES_PRIVATE_GROUP = 'Личная группа';
 TEXT_MES_COMMON_GROUP = 'Общая группа';
 TEXT_MES_GROUP_COMMENTA = '<Комментарий для группы>';
 TEXT_MES_NEW_GROUP_NAME = '<НоваяГруппа>';
 TEXT_MES_DELETE_GROUP_CONFIRM = 'Вы действительно хотите удалить эту группу?'+#13+'Группа = "%s"';
 TEXT_MES_ADD_GROUP = 'Добавление группы';
 TEXT_MES_DELETE_GROUP = 'Удаление группы';
 TEXT_MES_QUICK_GROUP_INFO = 'Информация о группе';
 TEXT_MES_CHANGE_GROUP_CAPTION = 'Изменить группу';
 TEXT_MES_QUICK_INFO_CAPTION = 'Информация о группе';
 TEXT_MES_GROUP_NOT_FOUND = 'Группа не найдена!';
 TEXT_MES_GROUP_CREATED_AT = 'Создана %s';
 TEXT_MES_GROUP = 'Группа';
 TEXT_MES_GROUP_ATTRIBUTES = 'Атрибуты:';
 TEXT_MES_GROUP_DATE_CREATED = 'Дата создания:';
 TEXT_MES_GROUP_COMMENT = 'Комментарий:';
 TEXT_MES_CHANGE_DATE_CAPTION = 'Изменить дату и время';
 TEXT_MES_GO_TO_CURRENT_DATE_ITEM = 'Перейти к текущей дате';
 TEXT_MES_DATE_NOT_EXISTS_ITEM = 'Даты нет';
 TEXT_MES_DATE_EXISTS_ITEM = 'Дата присутствует';
 TEXT_MES_SLIDE_CAPTION = 'Просмотр - %s   [%d/%d]';
 TEXT_MES_SLIDE_NEXT = 'Следующий';
 TEXT_MES_SLIDE_PREVIOUS = 'Предыдущий';
 TEXT_MES_SLIDE_TIMER = 'Таймер';
 TEXT_MES_SLIDE_STOP_TIMER = 'Остановить таймер';
 TEXT_MES_SLIDE_FIND_ITEM = TEXT_MES_FIND_TARGET;
 TEXT_MES_SLIDE_FULL_SCREEN = 'На весь экран';
 TEXT_MES_SLIDE_NORMAL = 'На нормальный экран';
 TEXT_MES_ADD_ONLY_THIS_FILE = 'Только этот файл';
 TEXT_MES_ADD_ALL_FOLDER = 'Все файлы в папке';
 TEXT_MES_ADD_TO_DB = 'Добавить в БД';
 TEXT_MES_DRAWING_FAILED = 'Ошибка прорисовки!';
 TEXT_MES_DBITEM_FORMAT = 'Пункт в БД [%s]';
 TEXT_MES_START_TIMER = 'Запустить таймер';
 TEXT_MES_STOP_TIMER = TEXT_MES_SLIDE_STOP_TIMER ;
 TEXT_MES_DATE_NOT_EXISTS_BOX = 'Дата отсутствует...';
 TEXT_MES_DATE_BOX_TEXT_TO_SET_DATE = 'Выберите "дата существует" в всплывающем меню...';
 TEXT_MES_DELETE_FROM_LIST = 'Удалить элемент из списка';
 TEXT_MES_SETUP_RUNNING = 'В данный момент запущена установка программы. Пожалуйста, закройте её и попытайтесь снова.';
 TEXT_MES_UNINSTALL_CONFIRM = 'Вы действительно хотите удалить эту программу?';
 TEXT_MES_APPLICATION_NOT_VALID = 'Приложение повреждено! Возможно, что оно инфицировано каким-либо вирусом!';
 TEXT_MES_REPLACE_GROUP = 'В базе данных найдена группа "%s". Что делать с этой группой при импорте в существующую БД?';
 TEXT_MES_ABORT = 'Прервать';
 TEXT_MES_SAVING_IN_PROGRESS = 'Сохранение выполняется...';
 TEXT_MES_SAVING_DATASET_CAPTION = 'Сохранение результатов';
 TEXT_MES_SAVING_GROUPS = 'Сохранение групп';
 TEXT_MES_SAVING_GROUPS_TEXT = 'Сохранение группы %s';
 TEXT_MES_ERROR_ADDING_GROUP = 'Ошибка создания группы "%s"';
 TEXT_MES_SELECT_TEMP_DIR = 'Пожалуйста, выберите директорию, куда будут записаны временные файлы. Её длинна не должна превышать 80 символов!';
 TEXT_MES_SELECT_TEMP_DIR_DIALOG = TEXT_MES_SELECT_TEMP_DIR;
// TEXT_MES_FILE_NOT_AVALIABLE_BDE = '<Не доступно пока BDE не установлено>';
 TEXT_MES_FILE_ONLY_MDB = '<Выберите файл если хотите импортировать данные>';
 TEXT_MES_HELP_NO_RECORDS_IN_DB_FOUND = 'Если Вы хотите добавить изображения в БД, выберите "Проводник" в контекстном меню';
 TEXT_MES_HELP_HINT = 'Помощь';
 TEXT_MES_GROUPS_REPLACE_CAPTION = 'Замена групп';
 TEXT_MES_READING_FOLDER_FORMAT = 'Чтение папки [%s Объектов найдено]';
 TEXT_MES_ALLOW_FAST_CLEANING = 'Разрешить быструю очистку';
 TEXT_MES_CHOOSE_GROUP_ACTION_ADD_GROUP = 'Добавить группу';
 TEXT_MES_CHOOSE_GROUP_ACTION_IMPORT_IN_GROUP = 'Импортировать в';
 TEXT_MES_CHOOSE_GROUP_ACTION_ADD_WITH_ANOTHER_NAME = 'Добавить с именем';
 TEXT_MES_CHOOSE_GROUP_ACTION_NO_NOT_ADD = 'Не добавлять эту группу';
 TEXT_MES_OLD_PASSWORD = 'Старый пароль';
 TEXT_MES_DONT_USE_EXT = 'Не использовать это расширение';
 TEXT_MES_USE_THIS_PROGRAM = 'Использовать эту программу по умолчанию';
 TEXT_MES_USE_ITEM = 'Использовать пункт в меню';
 TEXT_MES_SEARCH_PLUGINS = 'Поиск расширений...';
 TEXT_MES_AVALIABLE_THEMES = 'Доступные цветовые схемы:';
 TEXT_MES_DELETING_PLUGINS = 'Удаление расширений';
 TEXT_MES_DELETING_THEMES = 'Удаление тем';


 TEXT_MES_GROUPA = '<Группа>';

 TEXT_MES_WS_DATE_BETWEEN = 'Дата между';
 TEXT_MES_WS_RATING_BETWEEN = 'Оценка  между';
 TEXT_MES_WS_ID_BETWEEN = 'ID между';
 TEXT_MES_WS_SHOW_PRIVATE = 'Показывать личные';
 TEXT_MES_WS_SHOW_COMMON = 'Показывать общие';
 TEXT_MES_OPEN_IN_EXPLORER = 'Открыть в проводнике';

 TEXT_MES_ADD_OBJECT = 'Добавить объект';
 TEXT_MES_ADD_OBJECTS = 'Добавить объекты';

 TEXT_MES_NO_GROUPS = 'В вашей Базе Данных нет ни одной группы. Вы хотите создать новую группу?';

 TEXT_MES_CONVERTING = 'Обработка... (&%%)';
 TEXT_MES_REPLACE_EXT = 'Вы действительно хотите поменять расширение для объекта?';

 TEXT_MES_CHOOSE_ACTION = 'Выберите необходимое действие';
 TEXT_MES_PATH = 'Размещение';
 TEXT_MES_CURRENT_FILE_INFO = 'Текущая информация по файлу';
 TEXT_MES_REPLACE_AND_DELETE_DUBLICATES = 'Заменить и удалить дубликаты';
 TEXT_MES_SKIP = 'Пропустить';
 TEXT_MES_SKIP_FOR_ALL = 'Пропустить все';
 TEXT_MES_REPLACE = 'Заменить';
 TEXT_MES_REPLACE_FOR_ALL = 'Заменить все';
 TEXT_MES_ADD = 'Добавить';
 TEXT_MES_ADD_FOR_ALL = 'Добавить все';
 TEXT_MES_DELETE_FILE = 'Удалить файл';
 TEXT_MES_DELETE_FILE_CONFIRM = 'Вы действительно хотите удалить этот файл?';

 TEXT_MES_DB_FILE_INFO = 'Текущая информация по БД';
 TEXT_MES_UPDATER_CAPTION = 'Окно обновления БД';
 TEXT_MES_RECREATING_TH_TABLE = 'База';
 TEXT_MES_BEGIN_RECREATING_TH_TABLE = 'Начало обновления таблицы. Это долгое действие, пожалуйста - подождите... (чтобы прервать действие, нажмите Ctrl+B)';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT = 'Обновление записи %s из %s [%s]';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CRYPTED_POSTPONED = 'Обновление записи %s из %s [%s] отложено (зашифрована)';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CD_DVD_CANCELED_INFO_F = 'Обновление записи %s из %s [%s] отменено (CD\DVD файлы обновляются из окна управлениями дисками)';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CRYPTED_FIXED = 'Для записи %s из %s [%s] удалён предпросмотр (файл зашифрован, а запись - нет)';
 TEXT_MES_RECREATING = 'Обновление...';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_ERROR = 'Ошибка обновления записи %s';
 TEXT_MES_RECREATINH_TH_FORMAT_ERROR = 'Ошибка обновления записей';
 TEXT_MES_BREAK_RECREATING_TH = 'Вы действительно хотите отменить текущее действие?';
 TEXT_MES_ENTER_NAME_ERROR = 'Введите, пожалуйста, ваше имя';
 TEXT_MES_UPDATING_DESCTIPTION = 'Обновление БД';
 TEXT_MES_DB_EXISTS__USE_NEW = 'Конечная БД уже существует! Вы действительно хотите использовать новую таблицу "%s" (или добавить её)?'#13'YES - добавить записи'#13'NO - использовать новую таблицу (Старая будет УДАЛЕНА!)'#13'ABORT - не выполнять действий';
 TEXT_MES_SLIDE_SHOW_STEPS_OPTIONS = 'Количество шагов для Слайд-Шоу - %s';
 TEXT_MES_SLIDE_SHOW_GRAYSCALE_OPTIONS = 'Скорость для перехода в чёрно-белый цвет (загрузка) - %s.';
 TEXT_MES_USE_COOL_STRETCH = 'Использовать качественную прорисовку';
 TEXT_MES_SET_AS_DESKTOP_WALLPAPER = 'Сделать рисунком рабочего стола';
 TEXT_MES_SLIDE_SHOW_SLIDE_DELAY = 'Задержка между кадрами (%s)';
 TEXT_MES_USE_EXTERNAL_VIEWER = 'Использовать другой просмотрщик';
 TEXT_MES_MANAGE_GROUPS = 'Управление группами';

 TEXT_MES_NETWORK = 'Сеть';
 TEXT_MES_READING_NETWORK = 'Поиск сетей';
 TEXT_MES_READING_WORKGROUP = 'Поиск компьютеров';
 TEXT_MES_READING_COMPUTER = 'Открытие компьютера';
 TEXT_MES_WORKGROUP = 'Рабочая группа';
 TEXT_MES_COMPUTER = 'Компьютер';
 TEXT_MES_SHARE = 'Ресурс';
 TEXT_MES_ERROR_OPENING_COMPUTER = 'Ошибка открытия компьютера';
 TEXT_MES_ERROR_OPENING_WORKGROUP = 'Группа временно недоступна';
 TEXT_MES_ERROR_OPENING_FOLDER = 'Папка временно недоступна';
 TEXT_MES_ADDRESS = '  Адрес ';

 TEXT_MES_SEARCH_FOR_GROUP = 'Поиск фотографий группы';

 TEXT_MES_ZOOM_OUT = 'Увеличить';
 TEXT_MES_ZOOM_IN = 'Уменьшить';
 TEXT_MES_REAL_SIZE = 'Реальный размер';
 TEXT_MES_BEST_SIZE = 'Наилучший размер';
 
 TEXT_MES_ABOUT = 'О программе';
 TEXT_MES_ACTIVATION = 'Активация программы';
 TEXT_MES_HOME_PAGE = 'Сайт программы';
 TEXT_MES_CONTACT_WITH_AUTHOR = 'Связаться с автором';
 TEXT_MES_GET_CODE = 'Получить код';
 TEXT_MES_EXT_IN_USE = 'Текущие расширения:';

 TEXT_MES_IDAPI_INSTALL_CONFIRM = 'Установить BDE сейчас?';

 TEXT_MES_IDAPI_NOT_INSTELLED = 'Один из компонентов программы (BDE) установлен неверно. Пожалуйста, переустановите приложение';



 TEXT_MES_CRYPT_FILE = 'Зашифровать файл';
 TEXT_MES_DECRYPT_FILE = 'Расшифровать файл';
 TEXT_MES_REMOVE_IMAGE_PASS_F = 'Вы действительно хотите расшифровать файл "%s"?';
 TEXT_MES_PASSWORD_INVALID = 'Пароль неверен';
 TEXT_MES_PASSWORDS_DIFFERENT = 'Введённые пароли не совпадают!';
 TEXT_MES_DECRYPT = 'Расшифровать';
 TEXT_MES_CRYPTING = 'Шифрование';
 TEXT_MES_CRYPT = 'Зашифровать';
 TEXT_MES_ENTER_PASSWORD = 'Ввести пароль';
 TEXT_MES_ENTER_PASS_HERE = 'Введите пароль для открытия файла "%s" сюда:';

 TEXT_MES_CLOSE_PASSWORD_FILE_LIST = 'Убрать лист'; 
 TEXT_MES_SHOW_PASSWORD_FILE_LIST = 'Показать файлы';
 TEXT_MES_PASSWORD_FILE_LIST_INFO = 'Данные файлы, вероятнее всего, зашифрованы одним паролем.';

 TEXT_MES_MANY_FALES_PASSWORD_INFO = 'Введите пароль для открытия группы файлов (нажмите '+TEXT_MES_SHOW_PASSWORD_FILE_LIST+' для отображения списка) сюда:';
 TEXT_MES_SAVE_PASS_SESSION = 'Сохранить пароль на время работы';
 TEXT_MES_SAVE_PASS_IN_INI_DIRECTORY = 'Сохранить пароль в настройках (НЕ рекомендуется)';
 TEXT_MES_PASSWORD_NEEDED = 'Необходим пароль';
 TEXT_MES_CRYPT_IMAGE = 'Зашифровать объект(ы)';
 TEXT_MES_PASS = 'Введите сюда пароль:';
 TEXT_MES_PASS_CONFIRM = 'Подтверждение пароля:';
 TEXT_MES_SHOW_PASSWORD = 'Показывать пароль при вводе';
 TEXT_MES_SAVE_CRC = 'Сохранять контрольную сумму';

 TEXT_MES_LOADING_ICONS = 'Загрузка иконок...';

 TEXT_MES_EXPORT_CRYPTED_IF_PASSWORD_EXISTS = 'Экспортировать зашифрованные, если найден пароль';
 TEXT_MES_EXPORT_CRYPTED = 'Экспортировать зашифрованные записи';
 TEXT_MES_CANNOT_CREATE_FILE_F = 'Невозможно создать файл "%s"';

 TEXT_MES_ORIGINAL_FILE_NAME = 'Оригинальное имя файла';
 TEXT_MES_NEW_FILE_NAME = 'Новое имя файла';

 TEXT_MES_MASK_FOR_FILE = 'Маска имени объектов';
 TEXT_MES_BEGIN_MASK = 'Изображение #%3d [%date]';
 TEXT_MES_MASK_FOR_FILE_CAPTION = 'Массовое переименование файлов';
 TEXT_MES_INFO = 'Информация';
 TEXT_MES_MASK_INFO = 'Маска файла, в строке значение %d заменяется на порядковое число (если перед d стоит цифра, то она указывает количество лидирующих нулей)'#13'%date заменяется на текущую дату'#13'%fn - оригинальное имя файла (без расширения)';

 TEXT_MES_CONVERT = 'Конвертировать';
 TEXT_MES_RESIZE = 'Изменить размер';
 TEXT_MES_CHOOSE_FORMAT = 'Необходимо сначала выбрать формат!';
 TEXT_MES_JPEG_COMPRESS = 'JPEG компрессия (%d%%):';

 TEXT_MES_BY_CENTER = 'По центру';
 TEXT_MES_BY_TILE = 'Замостить';
 TEXT_MES_BY_STRETCH = 'Растянуть';
 TEXT_MES_ROTATE_IMAGE = 'Повернуть изображение';
 TEXT_MES_CHANGE_SIZE = 'Изменить размер';
 TEXT_MES_CHANGE_SIZE_CAPTION= 'Изменение размера изображений';
 TEXT_MES_CHANGE_SIZE_INFO = 'Вы можете изменить размер выбранных объектов и конвертировать их в другой формат. (если сохранение в данном формате не поддерживается, то он будет конвертирован принудительно)';
 TEXT_MES_CHANGE_SIZE_100x100 = 'Конвертировать в 100х100';
 TEXT_MES_CHANGE_SIZE_200x200 = 'Конвертировать в 200х200';
 TEXT_MES_CHANGE_SIZE_600x800 = 'Конвертировать в 600х800';
 TEXT_MES_CHANGE_SIZE_CUSTOM = 'Произвольный размер:';
 TEXT_MES_SAVE_ASPECT_RATIO = 'Сохранять пропорции';
 TEXT_MES_USE_ZOOM = 'Проценты от оригинального размера:';
 TEXT_MES_JPEG_OPTIONS = 'Опции JPEG';
 TEXT_MES_TRY_KEEP_ORIGINAL_FORMAT = 'По возможности оригинальный формат';
 TEXT_MES_CONVERT_TO = 'Конвертировать в:';
 TEXT_MES_FILE_ACTIONS = 'Файловые операции';
 TEXT_MES_REPLACE_IMAGES = 'Заменить исходное изображение';
 TEXT_MES_MAKE_NEW_IMAGES = 'Создавать новые изображения';
 TEXT_MES_SAVE_SETTINGS_BY_DEFAULT = 'Сохранить настройки';

 TEXT_MES_ROTATE_IMAGE_INFO = 'Вы можете повернуть выбранные объекты и конвертировать их в другой формат. (если сохранение в данном формате не поддерживается, то он будет конвертирован принудительно)';
 TEXT_MES_ROTATE_CAPTION = 'Повернуть изображения';

 TEXT_MES_CONVERT_IMAGE_INFO = 'Вы можете конвертировать выбранные объекты другой формат, указанный ниже:';
 TEXT_MES_CONVERT_CAPTION = 'Конвертирование изображений';
 TEXT_MES_JPEG_CAPTION = 'Компрессия JPEG';
 TEXT_MES_JPEG_INFO = 'Выберите режим для компрессии в JPEG формат:';
 TEXT_MES_JPEG_PROGRESSIVE_MODE = 'Прогрессивный режим';
 TEXT_MES_JPEG = 'JPEG';


 TEXT_MES_SECURITY_INFO = 'ВНИМАНИЕ: это опция всё ещё экспериментальная, используйте осторожно. Если Вы забыли пароль к каким-либо изображениям, их восстановить уже не удастся!';
 TEXT_MES_SECURITY_USE_SAVE_IN_SESSION = 'Автоматически сохранять пароли для текущей сессии';
 TEXT_MES_SECURITY_USE_SAVE_IN_INI = 'Автоматически сохранять пароли в настройках (НЕ РЕКОМЕНДУЕТСЯ)';
 TEXT_MES_SECURITY_CLEAR_SESSION = 'Очистить текущие пароли в сессии';
 TEXT_MES_SECURITY_CLEAR_INI = 'Очистить текущие пароли в настройках';
 TEXT_MES_SECURITY = 'Безопасность';

 TEXT_MES_REFRESH_ID = 'Обновить запись в БД';
 TEXT_MES_REFRESH ='Обновить';
 TEXT_MES_AUTO_ADD_KEYWORDS = 'Автоматически добавлять ключевые слова';
 TEXT_MES_COMMENTS_FOR_GROUP = 'Комментарий для группы';
 TEXT_MES_KEYWORDS_FOR_GROUP = 'Ключевые слова для группы';

 TEXT_MES_ENTER_IM_PASSWORD = 'Введите пароль для объекта(ов):';
 TEXT_MES_REENTER_IM_PASSWORD = 'Подтвердите пароль:';

 TEXT_MES_SLIDE_CAPTION_EX = 'Просмотр - %s   [%dx%d] %f%%   [%d/%d]';
 TEXT_MES_SLIDE_CAPTION_EX_WAITING = 'Просмотр - %s   [%dx%d] %f%%   [%d/%d] - идёт загрузка списка остальных изображений...';

 TEXT_MES_NEW_SEARCH = 'Новое окно поиска';

 TEXT_MES_SHOW_DUBLICATES = 'Показать дубликаты';
 TEXT_MES_DUBLICATES = 'Дубликаты';
 TEXT_MES_DEL_DUBLICATES  = 'Удалить другие дубликаты';
 TEXT_MES_MANAGER_DB = 'Управление БД';

 TEXT_MES_UNABLE_SHOW_FILE_F = 'Невозможно отобразить файл:'#13'%s';
 TEXT_MES_DIRECT_X_FAILTURE = 'Ошибка инициализации графического режима';
 TEXT_MES_NEW_UPDATING_CAPTION = 'Доступна новая версия - %s';
 TEXT_MES_DOWNLOAD_NOW = 'Загрузить сейчас!';
 TEXT_MES_REMAIND_ME_LATER = 'Напомнить мне потом';
 TEXT_MES_NEW_COMMAND = 'Новый пункт меню';
 TEXT_MES_USER_MENU = 'Меню';
 TEXT_MES_USER_SUBMENU = 'Дополнительно';
 TEXT_MES_USER_MENU_ITEM = 'Пункт меню';
 TEXT_MES_CAPTION = 'Заголовок';
 TEXT_MES_EXECUTABLE_FILE = 'Исполняемый файл';
 TEXT_MES_EXECUTABLE_FILE_PARAMS = 'Параметры запуска';
 TEXT_MES_ICON = 'Иконка';
 TEXT_MES_USE_SUBMENU = 'Добавить в субменю';

 TEXT_MES_USER_SUBMENU_ICON = 'Иконка субменю';
 TEXT_MES_USER_SUBMENU_CAPTION = 'Заголовок субменю';
 TEXT_MES_USE_USER_MENU_FOR_ID_MENU = 'ID Меню';
 TEXT_MES_USE_USER_MENU_FOR_VIEWER = 'Просмотра';
 TEXT_MES_USE_USER_MENU_FOR_EXPLORER = 'Проводника';
 TEXT_MES_USE_USER_MENU_FOR = 'Использовать меню для:';
 TEXT_MES_REMOVE_USER_MENU_ITEM = 'Удалить';
 TEXT_MES_ADD_NEW_USER_MENU_ITEM = 'Добавить новый пункт';

 TEXT_MES_SORT_BY_FILE_NAME = 'Сортировать по имени файла';
 TEXT_MES_SORT_BY_FILE_SIZE = 'Сортировать по размеру файла';
 
 TEXT_MES_NEEDS_INTERNET_CONNECTION = 'Невозможно получить информацию об обновлениях т.к. не обнаружено соединения с интернетом';
 TEXT_MES_CANNOT_FIND_SITE = 'Не удалось получить информацию об обновлениях';
 TEXT_MES_NO_UPDATES = 'Не обнаружено новых версий программы';
 TEXT_MES_GET_UPDATING = 'Проверить обновления';
 TEXT_MES_ITEM_DOWN = 'Вниз';
 TEXT_MES_ITEM_UP = 'Вверх';
 TEXT_MES_CAN_CHANGE_EXT = 'Изменить расширение';
 TEXT_MES_MANY_FILES_F = '%d объектов';
 TEXT_MES_DO_SLIDE_SHOW = 'Слайд-Шоу';
 TEXT_MES_DB_INFO = 'Информация из БД:';
 TEXT_MES_BEGIN_NO = 'Начать с:';
 TEXT_MES_NEXT_HELP = 'Далее...';
 TEXT_MES_HELP_FIRST = '     Для добавления фотографий в Базу Данных (БД) выберите пункт "Проводник" в контекстном меню, затем найдите ваши фотографии и в меню выберите "добавить объекты".'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13#13;
 TEXT_MES_CLOSE_HELP = 'Вы действительно хотите отказаться от помощи?';
 TEXT_MES_HELP_1 = '     Найдите в проводнике папку с вашими фотографиями и, выделив фотографии, в меню выберите "Добавить объект(ы)".'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;
 TEXT_MES_HELP_2 = '     Нажмите на кнопку "Добавить объект(ы)" чтобы добавить фотографии в БД. После этого к фотографии можно добавлять информацию.'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;
 TEXT_MES_HELP_3 = '     Теперь фотографии, у которых не отображается иконка (+) в верхнем левом углу находятся в БД. Они доступны по поиску в окне поиска и к ним доступно контекстное меню со свойствами. Дальнейшая справка доступна из главного меню (Справка -> Справка).'#13' '#13;

 TEXT_MES_APPLICATION_FAILED = 'Приложение было закрыто некорректно. Возможно, оно зависло. В некоторых случаях это может быть вызвано ошибкой в БД, что может быть устранено упаковкой БД. Вы хотите выполнить эту операцию сейчас?';
 TEXT_MES_SLIDE_SHOW_SPEED = 'Дополнительная задержка для Слайд-Шоу - %s ms.';
 TEXT_MES_FULL_SCREEN_SLIDE_SPEED = 'Скорость слайдов для полноэкранного режима - %s ms.';

 TEXT_MES_CLEAR_FOLDER_IMAGES_CASH = 'Очистить кэш предпросмотров';
 TEXT_MES_CLEAR_ICON_CASH = 'Очистить кэш иконок';
 TEXT_MES_HELP_ACTIVATION_FIRST = '     Вы хотите получить справку, как активировать программу? Если ДА, то нажмите на кнопку "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;
 TEXT_MES_HELP_ACTIVATION_1 = '     Для активации программы в контекстном меню выберите пункт "Справка"->"Активация программы"'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;

 TEXT_MES_HELP_ACTIVATION_2 = '     Для активации программы в контекстном меню выберите пункт "Справка"->"Активация программы"'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;
 TEXT_MES_HELP_ACTIVATION_3 = '     Нажмите на кнопку "'+TEXT_MES_GET_CODE+'", после чего запустится почтовая программа с новым письмом, в заголовке которого дана вся необходимая для активации информация.'#13'вам необходимо отослать это письмо или же (если почтовая программа не запустилась)'+
 ' самим отправить письмо на адрес '+ProgramMail+', в котором нужно указать код программы и её версию.'#13#13+'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13#13' '#13;
 TEXT_MES_HELP_ACTIVATION_4 = '     В течении суток вам будет выслан код активации, который нужно ввести в это окно и нажать на кнопку "'+TEXT_MES_SET_CODE+'". После этого программа будет активирована.'#13' '#13;

 TEXT_MES_MENU_BUSY = 'Подождите завершения операции...';
 TEXT_MES_IMAGE_EDITOR_W ='Графический Редактор';
 TEXT_MES_IMAGE_EDITOR = 'Редактор';

 TEXT_MES_IM_LOADING_JPEG = 'Загрузка JPEG формата...';
 TEXT_MES_IM_LOADING_GIF = 'Загрузка GIF формата...';
 TEXT_MES_IM_LOADING_BMP = 'Загрузка BMP формата...';
 TEXT_MES_IM_UNDO = 'Отменить';
 TEXT_MES_IM_REDO = 'Повторить';
 TEXT_MES_CROP = 'Кадрирование';
 TEXT_MES_EFFECTS = 'Эффекты';
 TEXT_MES_COLORS = 'Цвета';
 TEXT_MES_RED_EYE = 'Красный глаз';
 TEXT_MES_IM_RESIZE = 'Размер';
 TEXT_MES_IM_REAL_SIZE = '100%';
 TEXT_MES_IM_FIT_TO_SIZE = 'Подогнать';
 TEXT_MES_IM_KEEP_PROPORTIONS = 'Сохранять пропорции:';
 TEXT_MES_IM_CLOSE_TOOL_PANEL = 'Закрыть инструмент';
 TEXT_MES_IM_APPLY = 'Применить';

 TEXT_MES_IM_CHOOSE_ACTION = 'Выберите действие';
 TEXT_MES_IM_ROTATE_LEFT = 'Повернуть влево';
 TEXT_MES_IM_ROTATE_RIGHT = 'Повернуть вправо';
 TEXT_MES_IM_ROTATE_180 = 'Повернуть на 180';
 TEXT_MES_IM_FLIP_HORISONTAL = 'Отразить по горизонтали';
 TEXT_MES_IM_FLIP_VERTICAL = 'Отразить по вертикали';
 TEXT_MES_IM_ROTATE_USTOM_ANGLE = 'Произвольный угол';
 TEXT_MES_IM_ACTION = 'Действия';
 TEXT_MES_BK_COLOR = 'Цвет фона';
 TEXT_MES_IM_USE_ZOOM = 'Проценты от размера:';

 TEXT_MES_WAIT_ACTION = 'Пожалуйста, подождите, пока программа выполнит текущую операцию и обновит базу данных.';
 TEXT_MES_SET = 'Установить';

 TEXT_MES_USER_CHANGE_ACCESS = 'Изменить права';
 TEXT_MES_SELECT_RIGHTS_F = 'Выберите права для пользователя "%s" и нажмите на кнопку "'+TEXT_MES_OK+'"';

 TEXT_MES_RIGHTS_DELETE = 'Удаление';
 TEXT_MES_RIGHTS_ADD = 'Добавление';
 TEXT_MES_RIGHTS_CHANGE_DB_NAME = 'Изменение БД';
 TEXT_MES_RIGHTS_SET_PRIVATE = 'Установка личных атрибутов';
 TEXT_MES_RIGHTS_SET_RATING = 'Установка оценки';
 TEXT_MES_RIGHTS_SET_INFO = 'Установка информации';
 TEXT_MES_RIGHTS_CHANGE_PASSWORD = 'Изменение пароля';
 TEXT_MES_RIGHTS_EDIT_IMAGE = 'Запуск редактора';
 TEXT_MES_RIGHTS_SHOW_PRIVATE = 'Показ личных фотографий';
 TEXT_MES_RIGHTS_SHOW_OPTIONS = 'Показывать опции';
 TEXT_MES_RIGHTS_ADMIN_TOOLS = 'Показывать системные настройки';
 TEXT_MES_RIGHTS_CRITICAL_FILE_OPERATIONS = 'Критические файловые операции';
 TEXT_MES_RIGHTS_NORMAL_FILE_OPERATIONS = 'Безопасные файловые операции';
 TEXT_MES_RIGHTS_MANAGE_GROUPS = 'Управление группами';
 TEXT_MES_RIGHTS_EXECUTE = 'Выполнение';
 TEXT_MES_RIGHTS_CRYPT = 'Шифрование';
 TEXT_MES_RIGHTS_SHOW_PATH = 'Показывать путь';
 TEXT_MES_RIGHTS_PRINT = 'Печать';
 TEXT_MES_RIGHTS_EDIT_GROUPS = 'Редактировать группы';

 TEXT_MES_SORT_BY_ID = 'Сортировка по ID';
 TEXT_MES_SORT_BY_NAME = 'Сортировка по имени';
 TEXT_MES_SORT_BY_RATING = 'Сортировка по оценке';
 TEXT_MES_SORT_BY_DATE = 'Сортировка по дате';
 TEXT_MES_SORT_BY_SIZE = 'Сортировка по размеру';
 TEXT_MES_SORT_BY_FILESIZE = 'Сортировка по файлу';
 
 TEXT_MES_SORT_INCREMENT = 'По возрастанию';
 TEXT_MES_SORT_DECREMENT = 'По убыванию';

 TEXT_MES_OTHER_TASKS = 'Другие задачи';
 TEXT_MES_EXPORT_IMAGES = 'Экспорт изображений';
 TEXT_MES_FONT = 'Шрифт';
 TEXT_MES_EXPORT_IMAGES_INFO = 'При помощи данного диалога Вы можете экспортировать фотографии из БД, применяя к ним преобразования размеров,'+
 ' опцию поворота из БД, а также добавлять к фотографиям "личную подпись"';
 TEXT_MES_OUTPUT_FOLDER = 'Конечная папка';
 TEXT_MES_APPLY_TRANSFORM = 'Применить изменение размеров:';
 TEXT_MES_ADD_COPYRIGHT_TEXT = 'Добавить личную подпись:';
 TEXT_MES_APLY_ROTATE = 'Повернуть изображения';
 TEXT_MES_OPEN_FILE = 'Открыть файл';

 TEXT_MES_CONTRAST = 'Контрастность: [%d]';
 TEXT_MES_BRIGHTNESS = 'Яркость : [%d]';
 TEXT_MES_RED_EYE_EFFECT_SIZE_F = 'Сила [%d]';
 TEXT_MES_SEL_FOLDER_TO_IMAGES = 'Выберите папку, куда будут сохранены изображения и нажмите на кнопку "'+TEXT_MES_OK+'"';

 TEXT_MES_FULL_SCREEN = 'На весь экран';

 TEXT_MES_R_F = 'R [%d]';
 TEXT_MES_G_F = 'G [%d]';
 TEXT_MES_B_F = 'B [%d]';

 TEXT_MES_NEW_TEXT_LABEL_CAPTION = 'Текст:';
 TEXT_MES_NEW_TEXT_LABEL = 'Мой текст';

 TEXT_MES_FONT_NAME_LABEL_CAPTION = 'Имя шрифта:';
 TEXT_MES_FONT_NAME_EDIT = 'Мой текст';
 TEXT_MES_FONT_SIZE_LABEL_CAPTION = 'Размер шрифта';
 TEXT_MES_FONT_COLOR = 'Цвет шрифта';
 TEXT_MES_SAVE_SETTINGS = 'Сохранить настройки';

 TEXT_MES_TEXT_ROTATION_0 = 'Нормальный текст';
 TEXT_MES_TEXT_ROTATION_90 = 'Повёрнут на 90*';
 TEXT_MES_TEXT_ROTATION_180 = 'Повёрнут на 180*';
 TEXT_MES_TEXT_ROTATION_270 = 'Повёрнут на 270*';
 TEXT_MES_TEXT_ROTATION = 'Поворот текста';

 TEXT_MES_ORIENTATION_LABEL = 'Ориентация текста';

 TEXT_MES_EDITOR_BRUSH_SIZE_LABEL = 'Размер кисти [%d]';
 TEXT_MES_EDITOR_BRUSH_COLOR_LABEL = 'Цвет кисти';

 TEXT_MES_EDITOR_ENABLE_OUTLINE_TEXT = 'Подсветка текста';
 TEXT_MES_EDITOR_OUTLINE_TEXT_SIZE = 'Величина:';
 TEXT_MES_OUTLINE_TEXT_COLOR = 'Цвет:';

 TEXT_MES_PRINT = 'Печать';
 TEXT_MES_SEL_FOLDER_FOR_IMAGES = 'Выберите папку для размещения изображений';
 TEXT_MES_USE_ANOTHER_FOLDER = 'Использовать папку:';
 TEXT_MES_TYPE = 'Формат';
 TEXT_MES_PHOTO = 'Фото:';
 TEXT_MES_D_ITEMS = '%d фото';

 TEXT_MES_ADD_PRINTER = 'Добавить принтер';
 TEXT_MES_PRINTER_SETUP = 'Настройки принтера';
 TEXT_MES_DO_PRINT = 'Напечатать';
 TEXT_MES_PRINTER_MAIN_FORM_CAPTION = 'Форма печати изображений';
 TEXT_MES_GENERATING_PRINTER_PREVIEW = 'Генерация предпросмотра для печати';
 TEXT_MES_PRINTING = 'Идёт печать...';
 TEXT_MES_WAIT_UNTIL_PRINTING = 'пожалуйста, подождите пока производится вывод на печать...';

 TEXT_MES_TPSS_FULL_SIZE = 'Полный размер';
 TEXT_MES_TPSS_C35 = '35 фотографий на странице';
 TEXT_MES_TPSS_20X25C1 = '20x25 см, 1 фото';
 TEXT_MES_TPSS_13X18C1 = '13x18 см, 1 фото';
 TEXT_MES_TPSS_13X18C2 = '13x18 см, 2 фото';
 TEXT_MES_TPSS_10X15C1 = '10x15 см, 1 фото';
 TEXT_MES_TPSS_10X15C2 = '10x15 см, 2 фото';
 TEXT_MES_TPSS_10X15C3 = '10x15 см, 3 фото';
 TEXT_MES_TPSS_9X13C1 = '9x13 см, 1 фото';
 TEXT_MES_TPSS_9X13C2 = '9x13 см, 2 фото';
 TEXT_MES_TPSS_9X13C4 = '9x13 см, 4 фото';
 TEXT_MES_TPSS_C9 = '9 фотографий на странице';
 TEXT_MES_TPSS_4X6C4 = '4x6 см, 1 фото в 4х отпечатках';
 TEXT_MES_TPSS_3X4C6 = '3x4 см, 1 фото в 6х отпечатках';

 TEXT_MES_CURRENT_FORMAT = 'Текущий формат:';
 TEXT_MES_PRINT_RANGE = 'Область печати';
 TEXT_MES_PRINT_RANGE_CURRENT = 'Текущую страницу';
 TEXT_MES_PRINT_RANGE_ALL = 'Все страницы';
 TEXT_MES_COPY_TO_FILE = 'Копировать в файл';
 TEXT_MES_CROP_IMAGES = 'Кадрировать фото';
 TEXT_MES_USE_CUSTOM_SIZE = 'Произвольный размер';
 TEXT_MES_CUSTOM_SIZE = 'Произвольный размер:';
 TEXT_MES_PAGE = 'Страница';
 TEXT_MES_PRINT_FORMATS = 'Форматы печати';
 TEXT_MES_MAKE_IMAGE = 'Сделать изображение';

 TEXT_MES_EXIF = 'EXIF';
 TEXT_MES_GISTOGRAMM = 'Гистограмма';
 TEXT_MES_GISTOGRAMM_IMAGE = 'Изображение гистограммы';
 TEXT_MES_EFFECTIVE_RANGE_F = 'Эффективный диапазон - %d..%d';
 TEXT_MES_CHANEL = 'Канал';
 TEXT_MES_CHANEL_GRAY = 'Чёрно\белое';
 TEXT_MES_CHANEL_R = 'Красный канал';
 TEXT_MES_CHANEL_G = 'Зелёный канал';
 TEXT_MES_CHANEL_B = 'Синий канал';

 TEXT_MES_BRUSH = 'Кисть';

 TEXT_MES_OTHER_PLACES = 'Другие места';
 TEXT_MES_MY_PICTURES = 'Мои картинки';
 TEXT_MES_MY_DOCUMENTS = 'Мои документы';
 TEXT_MES_DESKTOP = 'Рабочий стол';

 TEXT_MES_SHADOW_COLOR = 'Цвет "тени"';
 TEXT_MES_ACTIONS = 'Действия';
 TEXT_MES_EXPORT = 'Экспорт';
 TEXT_MES_TEXT = 'Текст';
 TEXT_MES_PRINT_SELECT_FORMAT = '    Выберите формат для печати в списке слева и дважды кликните на выбранном формате';

 TEXT_MES_FILE_EXISTS_REPLACE = 'Файл "%s" уже существует! Вы хотите его заменить?';
 TEXT_MES_VIRTUAL_FILE = 'Виртуальный файл, свойства недоступны.';
 TEXT_MES_SELECTED_OBJECTS = 'Выбранные объекты';
 TEXT_MES_IMAGE_CHANGED_SAVE_Q = 'Изображение было изменено, сохранить?';
 TEXT_MES_CANT_OPEN_IMAGE_BECAUSE_EDITING = 'Невозможно открыть изображение т.к. выполняется редактирование другого изображения.';
 TEXT_MES_CANT_SAVE_IMAGE_BECAUSE_USER_HAVENT_RIGHTS = 'Невозможно сохранить изображение т.к. пользователь не имеет прав на замену изображений';

 TEXT_MES_SHOW_EXIF_MARKER = 'Показывать EXIF заголовок';

 TEXT_MES_GROUP_ALREADY_EXISTS = 'Группа с таким именем уже существует! Пожалуйста, выберите другое имя';
 TEXT_MES_NEW_GROUP = '<Новая группа>';
 TEXT_MES_USE_SCANNING_BY_FILENAME = 'Использовать узнавание при совпадении имени';
 TEXT_MES_SHOW_OTHER_PLACES = 'Отображать ссылки "Другие места"';

 TEXT_MES_PROGRESS_FORM = 'Выполняется действие';
 TEXT_MES_NO_USB_DRIVES = 'Не найдено съёмных дисков';
 TEXT_MES_GET_PHOTOS = 'Получить фотографии';
 TEXT_MES_REMOVEBLE_DRIVE = 'Съёмный носитель';
 TEXT_MES_OPEN_THIS_FOLDER = 'Открыть эту папку';
 TEXT_MES_GET_PHOTOS_CAPTION = 'Получение фотографий';
 TEXT_MES_PHOTOS_DATE = 'Дата фотографий:';
 TEXT_MES_FOLDER_MASK = 'Маска имени папки:';
 TEXT_MES_COMMENT_FOR_FOLDER = 'Комментарий к папке:';
 TEXT_MES_YOU_COMMENT = 'Ваш комментарий';
 TEXT_MES_END_FOLDER_A = 'Конечная папка:';
 TEXT_MES_METHOD_A = 'Метод:';
 TEXT_MES_MOVE = 'Переместить';
 TEXT_MES_FOLDER_NAME_A = 'Имя папки:';
 TEXT_MES_YEAR_A = 'г.';
 TEXT_MES_CANT_CREATE_DIRECTORY_F = 'Невозможно создать директорию: "%s"';
 TEXT_MES_PHOTOS_NOT_FOUND_IN_DRIVE_F = 'Фотографии на носителе "%s" не найдены';
 TEXT_MES_NO_EXIF_HEADER = 'Exif заголовок не найден';
// 'Exif Header is not valid'
 TEXT_MES_GET_MULTIMEDIA_FILES = 'Получать мультимедийные файлы';
 TEXT_MES_INSERT_IMAGE = 'Вставка';

 TEXT_MES_SHOW_LAST = 'За последние:';
 TEXT_MES_SHOW_LAST_DAYS = 'дней';
 TEXT_MES_SHOW_LAST_WEEKS = 'недель';
 TEXT_MES_SHOW_LAST_MONTH = 'месяцев';
 TEXT_MES_SHOW_LAST_YEARS = 'лет';

 TEXT_MES_LOAD_IMAGE = 'Загрузить изображение';
 TEXT_MES_NEW_EDITOR = 'Новый редактор';
 TEXT_MES_COPY_CURRENT_ROW = 'Копировать текущую строку';
 TEXT_MES_COPY_ALL_INFO = 'Копировать всю информацию';

 TEXT_MES_SPEC_QUERY = 'Вставка специального запроса:';
 TEXT_MES_DELETED = 'Удалённые';

 TEXT_MES_NEW_TEXT_FILE = 'Текстовый файл';
 TEXT_MES_MAKE_NEW = 'Создать новый...';
 TEXT_MES_MAKE_NEW_TEXT_FILE = 'Текстовый файл';
 TEXT_MES_UNABLE_TO_CREATE_FILE_F = 'Невозможно создать файл "%s"';
 TEXT_MES_UNABLE_TO_CREATE_DIRECTORY_F = 'Невозможно создать директорию "%s"';
 TEXT_MES_NEXT_ON_CLICK = '"Следующий" при клике';
 TEXT_MES_INCLUDE_IN_BASE_SEARCH = 'Добавлять в базовый поиск';
 TEXT_MES_LINKS_FOR_PHOTOS = 'Ссылки к фотографии(ям)';

 TEXT_MES_LINKS = 'Ссылки';

 TEXT_MES_ADD_LINK = 'Добавить ссылку';
 TEXT_MES_EDIT_LINK = 'Изменить ссылку';

 TEXT_MES_LINK_TYPE = 'Тип ссылки';
 TEXT_MES_LINK_NAME = 'Имя ссылки';
 TEXT_MES_LINK_VALUE = 'Значение';
 TEXT_MES_LINK_FORM_CAPTION = 'Установите значение ссылки';
 TEXT_MES_SELECT_DIRECTORY = 'Выберите директорию';
 TEXT_MES_ADDITIONAL = 'Дополнительно';
 TEXT_MES_ADDITIONAL_PROPERTY = 'Ссылки';
 TEXT_MES_OPEN_FOLDER = 'Открыть папку';
 TEXT_MES_USE_HOT_SELECT_IN_LISTVIEWS = 'Использовать выделение при наведении в списках';
 TEXT_MES_CHANGE_LINK = 'Изменить ссылку';
 TEXT_MES_GLOBAL = 'Глобальные';
 TEXT_MES_CANT_ADD_LINK_ALREADY_EXISTS = 'Ссылка с таким именем уже существует!'#13'Пожалуйста, укажите другое имя';
 TEXT_MES_ROTATE_WITHOUT_PROMT = 'Поворачивать изображение на диске не спрашивая подтверждения';
 TEXT_MES_ROTATE_EVEN_IF_FILE_IN_DB = 'Даже если файл в БД, поворачивать на диске';

 TEXT_MES_VIEW_SC_LEFT_ARROW = 'Назад (Стрелка влево)';
 TEXT_MES_VIEW_SC_RIGHT_ARROW = 'Вперёд (Стрелка вправо)';
 TEXT_MES_VIEW_SC_FIT_TO_SIZE = 'Подогнать под окно (Ctrl+F)';
 TEXT_MES_VIEW_SC_FULL_SIZE = 'Реальный размер (Ctrl+A)';
 TEXT_MES_VIEW_SC_SLIDE_SHOW = 'Слайд-шоу (Ctrl+S)';
 TEXT_MES_VIEW_SC_FULLSCREEN = 'На весь экран (Ctrl+Enter)';
 TEXT_MES_VIEW_SC_ZOOM_IN = 'Уменьшить (Ctrl+I)';
 TEXT_MES_VIEW_SC_ZOOM_OUT = 'Увеличить (Ctrl+O)';
 TEXT_MES_VIEW_SC_ROTATE_LEFT = 'Повернуть влево (Ctrl+L)';
 TEXT_MES_VIEW_SC_ROTATE_RIGHT = 'Повернуть вправо (Ctrl+R)';
 TEXT_MES_VIEW_SC_DELETE = 'Удалить (Ctrl+D)';
 TEXT_MES_VIEW_SC_PRINT = 'Печать (Ctrl+P)';
 TEXT_MES_VIEW_SC_RATING = 'Рейтинг (Ctrl+оценка)';
 TEXT_MES_VIEW_SC_EDITOR = 'Редактор (Ctrl+E)';
 TEXT_MES_VIEW_SC_INFO = 'Свойства (Ctrl+Z)';

 TEXT_MES_USE_WIDE_SEARCH = 'Расширенный поиск';
 TEXT_MES_VAR_VALUES = 'Различные значения';
 TEXT_MES_QUERY_FAILED = 'Если данная ошибка возникает постоянно, то в контекстном меню выберите пункт "'+TEXT_MES_MANAGE_DB+'"'+#13' и в появившемся окне нажмите на кнопку "'+TEXT_MES_PACK_TABLE+'",'+#13' после чего нажмите "ДА\OK" и перезагрузите приложение';
 TEXT_MES_DIRECTORY_NOT_EXISTS_F = 'Директория "%s" не найдена';
 TEXT_MES_SORT_GROUPS = 'Сортировать группы';
 TEXT_MES_INCLUDE_IN_QUICK_LISTS = 'Включать в список быстрого поиска';
 TEXT_MES_RELATED_GROUPS = 'Связанные группы';

 TEXT_MES_NEED_FILESD_PLEASE_WAIT_F = 'В файл БД (%s) будет добавлено новое поле "%s" необходимое для работы, пожалуйста, подождите некоторое время после нажатия на кнопку Ok\Да';
 TEXT_MES_EX_COPY = 'Копия';
 TEXT_MES_SELECT_PLACE_TO_COPY = 'Укажите место, куда скопировать данные файлы (с учётом папок)';
 TEXT_MES_COPY_WITH_FOLDER = 'Копировать с папкой';
 TEXT_MES_USE_GDI_PLUS = 'Использовать GDI+';
 TEXT_MES_GDI_PLUS_DISABLED_INFO = 'GDI+ недоступно, обратитесь к справке для решения проблемы';
 TEXT_MES_DB_PATH_INVALID = 'Неверный путь к БД!'#13'Путь не может содержать русских букв и специальных символов';
 TEXT_MES_DB_READ_ONLY_CHANGE_ATTR_NEEDED = 'Файл базы данных имеет атрибут "Только чтение"! Снимите атрибут и попробуйте снова';
 TEXT_MES_FRIENDS = 'Друзья';
 TEXT_MES_FAMILY = 'Семья';
 TEXT_MES_CANT_MAKE_ACTION_BECAUSE_USER_HAVENT_NORMAL_FILE_ACTION_RIGHTS = 'Невозможно выполнить действие т.к. пользователь не имеет прав на простые файловые операции';
 TEXT_MES_UNABLE_GET_PHOTOS_COPY_MOVE_ERROR = 'Произошла ошибка в процессе получения фотографий'+#13+'Возможно Вы пытаетесь переместить фотографии с носителя, который доступен только для чтения';
 TEXT_MES_ADDING_FOLDER = 'Получение списка файлов...';
 TEXT_MES_CANT_WRITE_TO_FILE_F = 'Невозможно записать в файл "%s"'#13'Возможно, файл занят другим приложением...';
 TEXT_MES_OPEN_ACTIVATION_FORM = 'Открыть форму активации';
 TEXT_MES_INSTALL_BDE_ANYWAY = 'Устанавливать BDE в любом случае';

//v2.0
 
 TEXT_MES_SHOW_ALL_GROUPS = 'Показывать все группы';
 TEXT_MES_DELETE_UNUSED_KEY_WORDS = 'Удалять ненужные ключевые слова';
 TEXT_MES_FIX_DATE_AND_TIME = 'Считывать дату с EXIF';
 TEXT_MES_MOVE_TO_GROUP = 'Переместить в группу';
 TEXT_MES_SELECT_GROUP = 'Выбор группы';
 TEXT_MES_SELECT_GROUP_TEXT = 'Выберите, пожалуйста, необходимую группу';
 TEXT_MES_UNABLE_TO_MOVE_GROUP_F = 'Ошибка при перемещении группы: "%s"';
 TEXT_MES_RELOAD_INFO = 'Перезагрузите окна с данными, чтобы просмотреть изменения';
 TEXT_MES_UNABLE_TO_RENAME_GROUP_F = 'Ошибка при переименовании группы: "%s"';
 TEXT_MES_UNABLE_TO_DELETE_GROUP_F = 'Ошибка при удалении группы: "%s"';
 TEXT_MES_GROUP_RENAME_GROUP_CONFIRM = 'Вы действительно хотите переименовать группу? (будет просканирована вся БД)';
 TEXT_MES_CREATE_BACK_UP_EVERY = 'Создавать резервную копию каждые:';
 TEXT_MES_DAYS = 'дней';
 TEXT_MES_DELETE_GROUP_IN_TABLE_CONFIRM = 'Вы хотите удалить упоминания от этой группе (%s) во всей БД? (желательно)';
 TEXT_MES_TIME_EXISTS = 'Время установлено';
 TEXT_MES_TIME_NOT_SETS = 'Время не установлено';

 TEXT_MES_DATE_EXISTS = 'Дата установлена';
 TEXT_MES_NO_DATE_1 = 'Даты нет';
 TEXT_MES_TIME = 'Время';
 TEXT_MES_TIME_NOT_EXISTS = 'Времени нет';
 TEXT_MES_MANY_INSTANCES_OF_PROEPRTY = 'Разрешить загрузку нескольких копий окна свойств';
 TEXT_MES_AND_OTHERS = ' и другие...';
 TEXT_MES_UNABLE_TO_SHOW_INFO_ABOUT_SELECTED_FILES = 'Ошибка при получении сведений о выделенных элементах!';
 TEXT_MES_MENU_NOT_AVALIABLE_0 = 'Невозможно показать меню (несуществующий файл)';
 TEXT_MES_ERROR_EXESQSL_BY_REASON_F = 'Ошибка при выполнении запроса:'#13'%s'#13'%s';
 TEXT_MES_GO_TO_CURRENT_TIME = 'Перейти к текущему времени';
 TEXT_MES_GROUPS_EDIT_INFO = 'Используйте кнопку "-->" чтобы добавить группы к выделенным объектам и кнопку "<--" чтобы удалить их';
 TEXT_MES_SEL_NEW_PLACE = 'Выберите папку';
 TEXT_MES_NEW_PLACE = 'Новое место';
 TEXT_MES_SHOW_PLACE_IN = 'Отображать в:';
 TEXT_MES_USER_DEFINED_PLACES = 'Дополнительные места:';
 TEXT_MES_PLACES = 'Места:';
 TEXT_MES_ACTION_BREAKED_ITEM_FORMAT = 'Действие было прервано на записи %s из %s [%s]';
 TEXT_MES_BACKUPS = 'Резервные копии:';
 TEXT_MES_RESTORE_DB = 'Восстановить';
 TEXT_MES_RESTORE_DB_CONFIRM_F = 'Вы действительно хотите восстановить эту копию БД ("%s")?'#13'(текущая БД будет перемещена в данное хранилище)'#13'Перезапустите приложение чтобы начать процесс восстановления';
 TEXT_MES_DELETE_DB_BACK_UP_CONFIRM_F = 'Вы действительно хотите удалить эту копию БД ("%s")?';
 TEXT_MES_RESTORING_TABLE = 'Восстановление БД:';
 TEXT_MES_BEGIN_RESTORING_TABLE = 'Начало обновления таблицы. Пожалуйста - подождите...';
 TEXT_MES_RESTORING = 'Восстановление';
 TEXT_MES_ERROR_CREATE_BACK_UP_DEFAULT_DB = 'Ошибка! Не удалось сделать резервную копию текущей БД!';
 TEXT_MES_ERROR_COPYING_DB = 'Не удалось восстановить БД (%s)! Текущая БД может быть повреждена или отсутствовать! После запуска попробуйте восстановить файл "%s" в котором находится резервная копия вашей БД';
 TEXT_MES_HELP_CREATE_ADMIN = 'Введите в это поле пароль (любой на ваше усмотрение) для учётной записи Администратора, и повторите этот пароль в поле "'+TEXT_MES_CONFIRM+'", после чего нажмите на кнопку "'+TEXT_MES_OK+'". Данный пароль будет использован для входа в БД.'#13#13;
 TEXT_MES_HELP_LOGIN = 'Введите пароль, который Вы назначили для учётной записи Администратора и нажмите на кнопку "'+TEXT_MES_LOG_ON+'".'#13'Используйте флаг "'+TEXT_MES_AUTO_LOG_ON+'" чтобы не вводить каждый раз пароль (вход будет осуществляться автоматически).'#13#13;
 TEXT_MES_SIZE_FORMATB = '%s из %s';
 TEXT_MES_FREE_SPACE = 'Свободно на диске';
// TEXT_MES_SQL_VERIFYING_FAILED = 'В ходе проверки одного из компонентов программы (BDE) произошла ошибка.'#13'Возможно, компонент установлен не полностью или ошибочно. Рекомендуется принудительная установка BDE.';
 TEXT_MES_SQL_VERIFYING_FAILED = 'BDE не установлено на компьютере и в комплекте установки файл "BdeInst.dll" отсутствует.'#13'Если вам необходимо работать со старой базой данных (от предыдущих версий) обратитесь за файлом на сайт программы';
 TEXT_MES_DBE_DLL_LOADING_FAILED_F = 'Ошибка загрузки файла "BdeInst.dll"!'#13'Возможно файл повреждён или отсутствует в пути:'#13'%s';
 TEXT_MES_GROUPS_LIST = 'Доступные группы:';
 TEXT_MES_CONTENTS = 'Содержание';
 TEXT_MES_SELECT_FONT = 'Выбрать шрифт';
 TEXT_MES_SELECT_FONT_INFO = 'Выберите необходимый шрифт из списка и нажмите на кнопку "'+TEXT_MES_OK+'"';
 TEXT_MES_OLD_FONT_NAME = 'Старый шрифт';
 TEXT_MES_NEW_FONT_NAME = 'Новый шрифт';
 TEXT_MES_USE_MAIN_MENU_IN_SEARCH_FORM = 'Показывать главное меню в окне поиска';
 TEXT_MES_OPEN_TABLE_ERROR_F = 'Ошибка открытия таблицы "%s"';
 TEXT_MES_LIST_OF_KEYWORDS_CAPTION = 'Список ключевых слов';
 TEXT_MES_LIST_OF_KEYWORDS_TEXT = 'В этом списке все ключевые слова из текущей базы данных. Дважды кликните по любому чтобы скопировать в буфер обмена.';
 TEXT_MES_GET_LIST_OF_KEYWORDS = 'Показать список ключевых слов';
 TEXT_MES_LOADING_KEYWORDS = 'Происходит составление списка, подождите пожалуйста...';
 TEXT_MES_CD_ROM_DRIVE = 'CD-ROM';
 TEXT_MES_NO_CD_ROM_DRIVES = 'Не найдено CD-ROM устройств';
 TEXT_MES_CD_ROM_DRIVES = 'CD-ROM диски';
 TEXT_MES_REMOVABLE_DRIVES = 'Съёмные диски';
 TEXT_MES_SPECIAL_LOCATION = 'Специальное размещение';
 TEXT_MES_SEL_FOLDER_IMPORT_PHOTOS = 'Выберите папку для импорта фотографий в БД:';
 TEXT_MES_PHOTOS_NOT_FOUND_IN_PACH_F = 'Фотографии по указанному пути: "%s" не найдены';
 TEXT_MES_MAKE_DB_TREE = 'Построить дерево по БД';
 TEXT_MES_MAKE_DB_TREE_CAPTION = 'Дерево файлов текущей БД';
 TEXT_MES_DO_MAKE_DB_TREE = 'Построить дерево';
 TEXT_MES_MAKEING_DB_TREE = 'Построение дерева...';
 TEXT_MES_ERROR_ITEM = 'Запись отсутствует';
 TEXT_MES_UNKNOWN = 'Неизвестно';
 TEXT_MES_YOU_HAVENT_RIGHTS_FOR_FULL_ACCESS_NEW_IMAGE_WILL_COPIED_IN_NEW_FILE = 'У вас недостаточно прав на полную версию данной операции. Новое изображение будет скопировано в новый файл.';
 TEXT_MES_CRYPT_FILE_WITHOUT_PASS_MOT_ADDED = 'Не удалось добавить в БД один или несколько файлов. Для уточнения выберите "История" в контекстном меню'#13#13;
 TEXT_MES_HISTORY = 'История';
 TEXT_MES_NO_HISTORY = 'История пуста';
 TEXT_MES_HISTORY_INFO = 'В данном списке находятся файлы, который по каким-либо причинам не были добавлены:';
 TEXT_MES_ASK_AGAIN = 'Не спрашивать более';
 TEXT_MES_FIXED_TH_FOR_ITEM = 'Обновлена информация у файла "%s"';
 TEXT_MES_FAILED_TH_FOR_ITEM = 'Не удалось получить информацию у файла "%s" по причине: %s';
 TEXT_MES_CURRENT_ITEM_F = 'Текущая запись %s из %s [%s]';
 TEXT_MES_CURRENT_ITEM_LINK_BAD = 'Неверная ссылка в записи #%d [%s]. Ссылка "%s" типа "%s"';
 TEXT_MES_BAD_LINKS_TABLE = 'Будет произведён поиск недействительных ссылок по БД:';
 TEXT_MES_BAD_LINKS_TABLE_WORKING = 'Выполняется поиск, пожалуйста, подождите... '#13'(по завершению лог будет скопирован в буфер обмена)';
 TEXT_MES_BAD_LINKS_TABLE_WORKING_1 = 'Выполняется поиск';
 TEXT_MES_RECREATE_IDEX_QUESTION = 'Вы действительно хотите переформировать IDEx в таблице? Восстановление начнётся при следующем запуске.';
 TEXT_MES_SHOW_BAD_LINKS_QUESTION = 'Вы действительно хотите сканировать таблицу на недействительные ссылки? Сканирование начнётся при следующем запуске.';
 TEXT_MES_RECTEATE_IDEX_CAPTION = 'Перестроить IDEx';
 TEXT_MES_BAD_LINKS_CAPTION = 'Битые ссылки';
 TEXT_MES_NEW_NAME = 'Новое имя';
 TEXT_MES_ENTER_NEW_NAME = 'Введите новое имя файла и нажмите на "'+TEXT_MES_OK+'"';
 TEXT_MES_RECORDS_ADDED = 'Записей добавлено';
 TEXT_MES_RECORDS_UPDATED = 'Записей обновлено';
 TEXT_MES_SCAN_IMAGE = 'Найти похожие';
 TEXT_MES_ALLOW_VIRTUAL_CURSOR_IN_EDITOR = 'Виртуальный курсор в редакторе';
 TEXT_MES_PATH_TOO_LONG = 'Путь к установочной программе очень длинный:'#13'%s'#13'В ходе установке могут возникнуть проблемы, чтобы их избежать - поместите программу в папку с более коротким путём';
 TEXT_MES_SHOW = 'Показать';
 TEXT_MES_USER = 'Пользователь';
 TEXT_MES_EDIT = 'Редактировать';
 TEXT_MES_GROUPS = 'Группы';
 TEXT_MES_NEW = 'Новое';   
 TEXT_MES_NEW_W = 'Новая';
 TEXT_MES_SAVE = 'Сохранить';
 TEXT_MES_COPY = 'Скопировать';
 TEXT_MES_STOP = 'Стоп';
 TEXT_MES_ERROR = 'Ошибка';
 TEXT_MES_PROCESSING = 'Обработка';
 TEXT_MES_ORIGINAL = 'Оригинал';
 TEXT_MES_ADD_PROC_IMTH_AND_ADD_ORIG_TO_PROC_PHOTO = 'Связать данное фото с обработкой (к обработке добавляется ссылка на этот оригинал)';
 TEXT_MES_ADD_PROC_IMTH = 'Связать данное фото с обработкой';

 TEXT_MES_ADD_ORIG_IMTH_AND_ADD_PROC_TO_ORIG_PHOTO = 'Связать данное фото с оригиналом (к оригиналу добавляется ссылка на эту обработку)';
 TEXT_MES_ADD_ORIG_IMTH = 'Связать данное фото с оригиналом';

 TEXT_MES_PACKING_WILL_BEGIN_AT_NEXT_STARTUP = 'Упаковка начнётся при следующем запуске программы!';

 TEXT_MES_BACK_UPING_WILL_BEGIN_AT_NEXT_STARTUP = 'Восстановление начнётся при следующем запуске программы!';
 TEXT_MES_BACK_UP_TABLE = 'Создание резервной копии БД';
 TEXT_MES_BACKUPING = 'Копирование';
 TEXT_MES_DB_BY_DEFAULT = 'БД';
 TEXT_MES_ENTER_NEW_NAME_FOR_DB = 'Новое имя для БД';
 TEXT_MES_DO_YOU_REALLY_WANT_TO_DENELE_DB_F = 'Вы действительно хотите удалить эту БД (%s)?';
 TEXT_MES_SELECT_BK_COLOR = 'Выбрать цвет фона';
 TEXT_MES_PRINT_ERROR_F = 'Невозможно открыть форму печати по причине: '#13'%s';
 TEXT_MES_ACTIONS_FORM = 'Действия';

 SORT_BY = 'Сортировать по...';    
 SORT_BY_NO_SORTING  = 'Без сортировки';
 SORT_BY_FILENAME  = 'Имени файла';
 SORT_BY_SIZE = 'Размеру';
 SORT_BY_TYPE = 'Типу';
 SORT_BY_MODIFIED  = 'Дате изменения';
 SORT_BY_RATING  = 'Оценке';
 SORT_BY_SET_FILTER = 'Установить фильтр';
 SORT_BY_NUMBER = 'Номеру';
 TEXT_MES_ENTER_FILTER = 'Введите фильтр (маску) на отображение файлов';
 TEXT_MES_FILTER = 'Фильтр';
 TEXT_MES_RENAME_FOLDER_WITH_DB_F = 'В данной папке (%s) содержится %s фотографий из БД!'#13'Скорректировать информацию в БД?';

 TEXT_MES_SEL_FOLDER_SPLIT_DB = 'Пожалуйста, выберите папку для размещения части БД';
 TEXT_MES_SPLIT_DB_CAPTION = 'Разбивка БД';
 TEXT_MES_DELETE_RECORDS_AFTER_FINISH = 'Удалить записи по окончанию';
 TEXT_MES_FILES_AND_FOLDERS = 'Файлы и папки:';
 TEXT_MES_SPLIT_DB_INFO = 'Перетащите в список файлы и папки, в которых содержатся изображения, которые необходимо перенести в другую БД';
 TEXT_MES_METHOD = 'Метод';
 TEXT_MES_SELECT_DB_PLEASE = 'Пожалуйста, выберите сперва базу данных';
 TEXT_MES_REALLY_SPLIT_IN_DB_F = 'Вы действительно хотите разбить БД и использовать данный файл:'#13'"%s" ?'#13'ВНИМАНИЕ:'#13'ВО время разбивки другие окна будут недоступны!';
 TEXT_MES_SELECTED_COLOR = 'Цвет выделения';
 TEXT_MES_RELOAD_DATA = 'Перезагрузить данные в окнах?';

 TEXT_MES_OPTIMIZE_TO_FILE_SIZE = 'Оптимизировать под размер:';
 TEXT_MES_WAINT_DB_MANAGER = 'Пожалуйста, подождите пока Менеджер БД откроется. Это может занять некоторое время...';
 TEXT_MES_WAINT_OPENING_QUERY = 'Пожалуйста, подождите пока выполниться запрос';

 TEXT_MES_DO_UPDATE_IMAGES_ON_IMAGE_CHANGES = 'Следить за изменением файлов и обновлять ссылки (замедляет работу - читайте help)';

 TEXT_MES_ENTER_TEXT = 'Введите текст';
 TEXT_MES_ENTER_CAPTION_OF_PANEL = 'Введите название панели:';
 TEXT_MES_APPLY_ACTION = 'Применить действия';

 TEXT_MES_APPLY_ACTION_DIR = 'Выберите директорию, куда будут помещаться обработанные файлы';
 TEXT_MES_WRITE_ERROR_F = 'Возникла ошибка при записи данных!'#13'%s';
 TEXT_MES_DRIVE_FULL = 'Диск переполнен!';

 TEXT_MES_DO_ADD_DB = 'Добавить БД';
 TEXT_MES_DB_TYPE = 'Тип БД:';
 TEXT_MES_DB_IS_OLD_DB = 'База данных Paradox оставлена в целях совместимости с предыдущими версиями'#13'Рекомендуется использовать БД Access';

 TEXT_MES_DELETING_SCRIPTS = 'Удаление скриптов';
 TEXT_MES_THEMES = 'Цветовые темы';                
 TEXT_MES_SCRIPTS = 'Скрипты';
 TEXT_MES_DEFAULT_DB_NAME = 'MyDB';
 TEXT_MES_SELECT_DB = 'Выбрать БД';
 TEXT_MES_MOVING_DB_INIT = 'Инициализация импорта! Может занять несколько минут';

 TEXT_MES_NO_RECORDS_FOUNDED_TO_SAVE = 'Нет найденных записей для сохранения';
 TEXT_MES_MAKE_FOLDERVIEWER = 'Создать БД-Вьювер';
 TEXT_MES_OPTIMIZANG_DUBLICATES = 'Оптимизация дубликатов... (Ctrl+B для прекращения)';
 TEXT_MES_OPTIMIZANG_DUBLICATES_WORKING = 'Выполняется сканирование БД, пожалуйста, подождите... ';
 TEXT_MES_OPTIMIZANG_DUBLICATES_WORKING_1 = 'Выполняется сканирование БД';
 TEXT_MES_OPTIMIZING_DUBLICATES = 'Оптимизировать дубликаты';
 TEXT_MES_OPTIMIZING_DUBLICATES_QUESTION = 'Вы действительно хотите оптимизировать дубликаты в таблице?'+#13+'Оптимизация начнётся при следующем запуске программы...';

 TEXT_MES_CURRENT_ITEM_UPDATED_DUBLICATES = 'Обновлена запись #%d [%s]';

 TEXT_MES_INCLUDE_SUBFOLDERS_QUERY = 'Включить подпапки?';
 TEXT_MES_DB_VIEW_ABOUT_F = 'Автономная база данных созданная с помощью "%s". В этой программе отключены многие функции, доступные в полной версии.';
 TEXT_MES_SELECT_FOLDER = 'Выберите папку';
 TEXT_MES_RUN_EXPLORER_AT_ATARTUP = 'Запускать проводник при запуске';
 TEXT_MES_USE_SPECIAL_FOLDER = 'Использовать папку';
 TEXT_MES_NO_ADD_SMALL_FILES_WITH_WH = 'Не добавлять в БД файлы, размером меньше:';
 TEXT_MES_LIST_DB_ITEMS_LOADING = 'Нельзя закрыть окно пока происходит загрузка списка!';

 TEXT_MES_SORT_BY_FILE_NUMBER = 'Сортировать по номеру файла';
 TEXT_MES_SORT_BY_MODIFIED = 'Сортировать по дате изменения';
 TEXT_MES_SORT_BY_FILE_TYPE = 'Сортировать по типу';

 TEXT_MES_WARNING_CONFLICT_RENAME_FILE_NAMES = 'Обнаружен конфликт имён файлов!'#13'При переименовании файлы могут иметь одинаковые имена, что недопустимо!'#13'Измените маску файлов чтобы убрать конфликт.';
 TEXT_MES_CONFLICT_FILE_NAMES = 'Конфликт имён файлов! ';
 TEXT_MES_UNKNOWN_DB_VERSION = 'Неизвестная версия БД';
 TEXT_MES_DIALOG_CONVERTING_DB = 'Этот диалог поможет вам конвертировать Вашу базу данных из одного формата в другой.';
 TEXT_MES_CONVERT_TO_BDE = 'Конвертировать в *.db (Paradox)';
 TEXT_MES_CONVERT_TO_MDB = 'Конвертировать в *.photodb (PhotoDB)';
 TEXT_MES_CONVERTING_CAPTION = 'Конвертирование БД';
 TEXT_MES_CONVERTING_FIRST_STEP = 'Выберите конечный тип БД для конвертирования (*.db (Paradox) БД доступна только при установленных соответствующих драйверах)';
 TEXT_MES_CONVERTING_SECOND_STEP = 'Подождите пока выполнится преобразование БД, это может потребовать несколько минут...';
 TEXT_MES_CONVERTING_IMAGE_SIZES_STEP = 'Вы можете настроить размеры и качество сжатия изображений в БД, а также выбрать размеры по умолчанию окон предпросмотра и контейнера изображений '+'(их можно изменить в дальнейшем без конвертации базы)';
 TEXT_MES_CONVERT_DB = 'Конвертировать БД';
 TEXT_MES_DO_YOU_REALLY_WANT_TO_CLOSE_THIS_DIALOG = 'Вы действительно хотите закрыть этот диалог?';
 TEXT_MES_CONVETRING_ENDED = 'Конвертирование БД завершено!';
 TEXT_MES_FINISH = 'Финиш!';


 TEXT_MES_CREATING_DB = 'Создание базы данных';
 TEXT_MES_CREATING_DB_OK = 'Создание БД успешно завершено';
 TEXT_MES_OPENING_DATABASES = 'Открытие БД';               
 TEXT_MES_CONVERTING_ENDED = 'Конвертирование завершено!';
 TEXT_MES_CONVERTION_IN_PROGRESS = 'Конвертирование структуры...';
 TEXT_MES_CONVERTING_DB_QUESTION = 'Вы хотите сконвертировать Вашу БД? Конвертирование начнётся после перезапуска программы.';
 TEXT_MES_UPDATING_SETTINGS_OK = 'Обновление настроек базы завершено!';
 TEXT_MES_IMPORT_IMAGES_CAPTION = 'Импорт ваших изображений в БД';
 TEXT_MES_IMPORTING_IMAGES_INFO = 'Этот диалог поможет вам добавить в БД ваши фотографии или другие изображения';

 TEXT_MES_IMPORTING_IMAGES_FIRST_STEP = 'Выберите папки откуда будут импортировать изображения';
 TEXT_MES_FOLDERS_TO_ADD = 'Папки для импорта';
 TEXT_MES_CURRENT_DB_FILE = 'Текущий файл БД';
 MAKE_MES_NEW_DB_FILE = 'Новый файл БД';
 TEXT_MES_DB_FILE = 'Файл БД';
 TEXT_MES_IMPORTING_IMAGES_SECOND_STEP = 'Выберите дополнительные опции импорта изображений.';
 TEXT_MES_IMPORTING_IMAGES_THIRD_STEP = 'Нажмите на "'+TEXT_MES_START_NOW+'" и подождите пока программа найдёт и добавит все ваши изображения. Это может потребовать много времени в зависимости от величины вашего фотоальбома.';
 TEXT_MES_AKS_ME = 'Спросить меня';
 TEXT_MES_IF_CONFLICT_IMPORTING_DO = 'При нахождении дубликатов';
 TEXT_MES_CALCULATION_IMAGES = 'Подсчёт изображений...';
 TEXT_MES_CURRENT_SIZE_F = 'Текущий размер - %s';
 TEXT_MES_IMAGES_COUNT_F = 'Найдено фотографий - %d';

 TEXT_MES_PROCESSING_IMAGES = 'Обработка изображений';
 TEXT_MES_PROCESSING_SIZE_F = 'Размер %s из %s';
 TEXT_MES_IMAGES_PROCESSED_COUNT_F = 'Обработано %d из %d';

 TEXT_MES_TIME_REM_F = 'Осталось времени - %s (&%%%%)'; //with progres

 TEXT_MES_WAIT_LOADING_WORK = 'Подождите пока программа восстановит сохранённую работу';

 TEXT_MES_CHOOSE_DATE_RANGE = 'Диапазон дат:';
 TEXT_MES_APPLY = 'Применить';

 TEXT_MES_LESS_THAN = 'Менее';
 TEXT_MES_MORE_THAN = 'Более';
 TEXT_MES_SHOW_DATE_OPTIONS = 'Настройка даты';
 TEXT_MES_RECORDS_FOUNDED = 'Найденные записи';
 TEXT_MES_OTHERS = 'Другое';
 TEXT_MES_BACKUPING_GROUP = 'Резервное копирование';
 TEXT_MES_SHOW_GROUPS_IN_SEARCH = 'Разбивать на группы в поисковике';
 TEXT_MES_PASSWORDS = 'Пароли';
 
 TEXT_MES_VIEW_THUMBNAILS = 'Эскизы страниц';
 TEXT_MES_VIEW_LIST = 'Список';
 TEXT_MES_VIEW_TILE = 'Плитка';
 TEXT_MES_VIEW_ICONS = 'Значки';   
 TEXT_MES_VIEW_LIST2 = 'Таблица';
 TEXT_MES_USE_WINDOWS_THEME = 'Тема Windows';

 TEXT_MES_CANNOT_RENAME_FILE = 'Ошибка при переименовании объекта';
 TEXT_MES_DB_NAME = 'Имя БД';
 TEXT_MES_ENTER_CUSTOM_DB_NAME = 'Введите имя новой БД:';
 TEXT_MES_DO_YOU_WANT_REPLACE_ICON_QUESTION = 'Вы хотите заменить иконку у конечной БД?';
 TEXT_MES_MOVING_FILES_NOW = 'В данный момент производится перемещение файлов в данном окне. Вы хотите закрыть окно? Если перемещаются файлы из БД то тогда не будет скорректирована информация из БД!';

 TEXT_MES_NO_PLACES_TO_IMPORT = 'Не выбрано ни одного пути для добавления - продолжение невозможно. Нажмите на кнопку "'+TEXT_MES_ADD_FOLDER+'" чтобы добавить путь к фотографиям.';

 TEXT_MES_FILES_ALREADY_EXISTS_REPLACE = 'Папка содержит уже файлы с такими именами, заменить их?';

 TEXT_MES_LOADING_BIG_IMAGES = 'Загрузка больших картинок';  
 TEXT_MES_LOADING_BIG_IMAGES_F = 'Загрузка больших картинок (%s)';

 TEXT_MES_BIG_IMAGE_FORM_SELECT = 'Размер картинок';
 TEXT_MES_BIG_IMAGE_SIZES = 'Размеры:';
 TEXT_MES_OTHER_BIG_SIZE_F = '%dx%d точек';

 TEXT_MES_PROGRAMM_NOT_INSTALLED = 'Программа не установлена корректно или запускается после перестановки системы.'#13'Вы хотите выполнить быструю регистрацию программы в системе?';
 TEXT_MES_ERROR_DURING_CONVERTING_IMAGE_F_DO_NEXT = 'Произошла ошибка при конвертации файла:'#13'%s'#13'Продолжить конвертирование?';
 TEXT_MES_ERROR_DURING_CONVERTING_IMAGE_F = 'Произошла ошибка при конвертации файла:'#13'%s';

 TEXT_MES_DO_YOU_REALLY_WANT_CANCEL_OPERATION = 'Вы действительно хотите прервать выполнение текущей операции?';

 TEXT_MES_LOADING___ = 'загрузка...';
 TEXT_MES_PHOTO_SERIES_DATES_ = 'Серии фотографий по датам:';
 TEXT_MES_ACTION_DOWNLOAD_DATE = 'Опции';

 TEXT_MES_SIMPLE_COPY_BY_DATE = 'Отдельная папка';
 TEXT_MES_MERGE_UP_BY_DATE = 'Совместить вверх';
 TEXT_MES_MERGE_DOWN_BY_DATE = 'Совместить вниз';
 TEXT_MES_DONT_COPY_BY_DATE = 'Не обрабатывать';
 TEXT_MES_SHOW_IMAGES = 'Показать изображения';
 TEXT_MES_SCAN_IMAGES_DATES = 'Сканирование папок';

 TEXT_MES_DO_YOU_REALLY_WANT_TO_THIS_ITEM = 'Вы действительно хотите удалить этот пункт?';
 TEXT_MES_ALL_GROUPS = 'Все группы';
 TEXT_MES_CLEAR_SEARCH_TEXT = '';
 TEXT_MES_NULL_TEXT = 'Пустой текст';
 TEXT_MES_SORTING = 'Сортировка';


 TEXT_MES_STENOGRAPHIA = 'Скрытие данных';
 TEXT_MES_DO_STENO = 'Скрыть данные в изображении';
 TEXT_MES_DO_DESTENO = 'Извлечь данные из изображения';
 TEXT_MES_FILE_IS_TOO_BIG = 'Файл слишком большой!';
 TEXT_MES_FILE_FILTER_FILES_LESS_THAN = 'Все файлы (Размер<%s)|*?*';
 TEXT_MES_FILE_NAME_F = 'Имя файла = "%s"';
 TEXT_MES_MAX_FILE_SIZE_F = 'Максимальный размер = %s';
 TEXT_MES_NORMAL_FILE_SIZE_F = 'Нормальный размер = %s';
 TEXT_MES_GOOD_FILE_SIZE_F = 'Наилучший размер = %s';
 TEXT_MES_FILE_SIZE_F = 'Размер файла - %s';
 TEXT_MES_INFORMATION_FILE_NAME = 'Файл с данными:';
 TEXT_MES_STENO_USE_FILTER = 'Использовать фильтр при выборе файла';
 TEXT_MES_STENO_USE_FILTER_MAX = 'Максимальный размер (заметное ухудшение качества)';
 TEXT_MES_STENO_USE_FILTER_NORMAL = 'Нормальный размер (практически незаметно)';
 TEXT_MES_STENO_USE_FILTER_GOOD = 'Лучший размер (незаметно)';
 TEXT_MES_OPEN_IMAGE = 'Открыть изображение';
 TEXT_MES_ADD_INFO_AND_SAVE_IMAGE = 'Добавить инф. и сохранить';
 TEXT_MES_DESTENO_IMAGE = 'Извлечь информацию';
 TEXT_MES_PHOTO_DB = 'Photo DataBase';
 TEXT_MES_ERROR_INITIALIZATION = 'Ошибка инициализации программы';
 TEXT_MES_ERROR_RUNNING = 'Ошибка во время выполнения программы';    
 TEXT_MES_ERROR_RUNNING_F = 'Ошибка во время выполнения программы: %s';
 ERROR_CREATING_APP_DATA_DIRECTORY_MAY_NE_PROBLEMS = 'Не удалось создать папку для хранения файлов с данными "%s"! Во время работы программы возможны проблемы!';
 ERROR_CREATING_APP_DATA_DIRECTORY_TEMP_MAY_BE_PROBLEMS = 'Не удалось создать папку для хранения файлов с временными данными "%s"! Во время работы программы возможны проблемы!';
 TEXT_MES_CONFIRMATION = 'Подтверждение';
 TEXT_MES_ERROR_MOVING_GROUP_F = 'Произошла ошибка во время перемещения группы %s в группу %s (%s)';
 TEXT_MES_STENO_IMAGE_IS_NOT_VALID = 'Изображение не содержит скрытую информацию или данный формат не поддерживается!';
 TEXT_MES_FILE_INFO_NOT_CRYPTED = 'Информация в файле не будет зашифрована!';
 TEXT_MES_FILE_INFO_NOT_VERIFYED = 'Информация повреждена в файле! Контрольная сумма не совпала!';
 TEXT_MES_CONVERTING_ERROR_F = 'Произошла ошибка во время конвертации базы! (%s)';
 TEXT_MES_UNKNOWN_DB = 'Неизвестная база';
 TEXT_MES_LOADING_PHOTODB = 'Загрузка PhotoDB '+TEXT_MES_PRODUCT_VERSION;

 TEXT_MES_CONVERTATION_JPEG_QUALITY = 'JPEG качество';
 TEXT_MES_CONVERTATION_JPEG_QUALITY_INFO = 'Устанавливает качество сжатия изображения, хранимых в базе. Принимает значение 1-100';
 TEXT_MES_CONVERTATION_TH_SIZE = 'Изображения в БД';
 TEXT_MES_CONVERTATION_TH_SIZE_INFO = 'При загрузке данных используется по умолчанию этот размер';
 TEXT_MES_CONVERTATION_HINT_SIZE = 'Предпросмотр';
 TEXT_MES_CONVERTATION_HINT_SIZE_INFO = 'Размер предпросмотра к изображениям';
 TEXT_MES_CONVERTATION_PANEL_PREVIEW_SIZE = 'Панель';
 TEXT_MES_CONVERTATION_PANEL_PREVIEW_SIZE_INFO = 'Размер изображений в панели по умолчанию';

 TEXT_MES_IMAGE_SIZE_FORMAT = 'Размер изображения = %s';
 TEXT_MES_DB_VERSION_INVALID_CONVERT_AVALIABLE = 'Данная БД не может быть использована без конвертирования, т.е. она создана для работы со старыми версиями программы. Запустить мастер конвертации баз?';
 TEXT_MES_INVALID_DB_VERSION_INFO = 'Файл был создан старой версией программы (ниже PhotoDB '+TEXT_MES_PRODUCT_VERSION+') и для корректной работы должен быть сконвертирован.';
 TEXT_MES_CANNOT_DELETE_FILE_NEW_NAME_F = 'Не удаётся удалить файл %s, возможно он занят другой программой или процессом. Будет использовано другое имя (имя_файла_1)';
 TEXT_MES_LOAD_DIFFERENT_IMAGE = 'Загрузить другое изображение';

 TEXT_MES_CLOSE_DIALOG = 'Закрыть диалог';
 TEXT_MES_SKIP_THIS_FILES = 'Пропустить эти файлы';
 TEXT_MES_COPY_TEXT = 'Копировать текст';
 TEXT_MES_RECREATING_PREVIEWS = 'Обновление предпросмотров в базе...';
 TEXT_MES_BACKUP_SUCCESS = 'Резервное копирование успешно завершено';
 TEXT_MES_PROSESSING_ = 'Выполняется:';
 TEXT_MES_FILES_MERGED = 'Файл объединён';
 TEXT_MES_RECORD_NOT_FOUND_F = 'Запись %d не найдена по ключу -> расширенный поиск';
 TEXT_MES_RECORD_NOT_FOUND_ERROR_F = 'Запись %d не найдена! [%s]';
 TEXT_MES_LOADING_BREAK = 'Загрузка прервана...';
 TEXT_MES_CANT_WRITE_EXIF_TO_FILE_F  = 'Ошибка записи EXIF-информации в файл! Файл будет сохранён без EXIF';
 TEXT_MES_CANT_MODIRY_EXIF_TO_FILE_F = 'Ошибка редактирование EXIF-информации для файла! Файл будет сохранён без изменения EXIF';
 TEXT_MES_DB_NAME_PATTERN = 'Новая база';
 TEXT_MES_USE_ANOTHER_DB_FILE = 'Использовать другой файл:';
 TEXT_MES_NEW_DB_FILE = '<Новый файл БД>';
 TEXT_MES_ERROR_DB_FILE_F = 'Неверный или несуществующий файл '#13'"%s"!'#13' Проверьте наличие файла или попробуйте добавить его через менеджер БД - возможно, файл был создан в предыдущей версии программы и необходимо его сконвертировать в текущую версию';
 TEXT_MES_THANGE_FILES_PATH_IN_DB = 'Сменить путь для файлов в базе';

 TEXT_MES_SHOW_HISTORY = 'Показать окно истории';
 TEXT_MES_UPDATER_OPEN_IMAGE = 'Открыть';
 TEXT_MES_UPDATER_OPEN_FOLDER = 'Проводник';
 TEXT_MES_PROCESSING_STATUS = 'Статус процесса:';
 TEXT_MES_UPDATER_INFO_SIZE_FORMAT = 'Чтение [%s]';
 TEXT_MES_READD_ALL = 'Добавить всё в базу ещё раз';
 TEXT_MES_ALL_FORMATS = 'Все форматы (%s)';
 TEXT_MES_ERROR_WRITING_THEME = 'Не удалось записать тему в файл!';
 TEXT_MES_CHANGE_DB_PATH_CAPTION = 'Изменить путь для файлов в базе';
 TEXT_MES_CHANGE_DB_PATH_INFO = 'Если у вас изменилось расположение большого числа файлов (к примеру, сменилась буква диска), то с помощью данного диалога можно быстро исправить данные о файлах в базе.';
 TEXT_MES_SCAN_IN_DB = 'Сканировать';
 TEXT_MES_CHOOSE_PATH = 'Выбрать';
 TEXT_MES_CHANGE_DB_PATH_FROM = 'Путь для замены:';  
 TEXT_MES_CHANGE_DB_PATH_TO = 'Новый путь:';
 TEXT_MES_CHOOSE_FOLDER = 'Выберите папку';
 TEXT_MES_CHANGE_ONLY_IF_END_PATH_EXISTS = 'Заменять только существующие пути';
 TEXT_MES_CHANGING_PATH_OK = 'Смена пути в БД прошла успешно! Всего заменено %d путей. Перезагрузите данные в окнах для применения изменений!';
 TEXT_MES_CHANGING_PATH_FAILED = 'При смене пути возникла ошибка:'#13'%s';
 TEXT_MES_SELECT_DB_CAPTION = 'Диалог выбора\создания\редактирования БД';
 TEXT_MES_SELECT_DB_OPTIONS = 'Выберите нужное действие';
 TEXT_MES_SELECT_DB_OPTION_1 = 'Создание нового файла Базы Данных';  
 TEXT_MES_SELECT_DB_OPTION_2 = 'Использовать существующий файл на жёстком диске';
 TEXT_MES_SELECT_DB_OPTION_3 = 'Использовать зарегистрированную базу';
 TEXT_MES_SELECT_DB_OPTION_STEP1 = 'Выберите нужное действие из списка и нажмите на кнопку "'+TEXT_MES_NEXT+'"';

 TEXT_MES_DB_NAME_AND_LOCATION = 'Название и месторасположение файлов';
 TEXT_MES_DB_ENTER_NEW_DB_NAME = 'Введите имя для новой базы';
 TEXT_MES_CHOOSE_NEW_DB_PATH = 'Выберите файл для новой базы';
 TEXT_MES_CHOOSE_ICON = 'Выбрать иконку';
 TEXT_MES_SELECT_DB_FILE = 'Выбрать файл';
 TEXT_MES_ICON_PREVIEW = 'Предпросмотр иконки';
 TEXT_MES_SELECT_ICON = 'Выбрать иконку';
 TEXT_MES_NO_DB_FILE_SELECTED = 'Не выбран файл базы данных! Выберите файл и попробуйте снова';
 TEXT_MES_VALUE  = 'Значение';

 TEXT_MES_NEW_DB_WILL_CREATE_WITH_THIS_OPTIONS = 'Новая база будет создана со следующими настройками:'#13#13;
 TEXT_MES_NEW_DB_NAME_FORMAT = 'Имя базы: "%s"';
 TEXT_MES_NEW_DB_PATH_FORMAT = 'Путь к базе: "%s"';  
 TEXT_MES_NEW_DB_ICON_FORMAT = 'Путь к иконке: "%s"';  
 TEXT_MES_NEW_DB_IMAGE_SIZE_FORMAT = 'Размер изображений в базе: %dpx';
 TEXT_MES_NEW_DB_IMAGE_QUALITY_FORMAT = 'Качество изображений: %dpx';
 TEXT_MES_NEW_DB_IMAGE_HINT_FORMAT = 'Предпросмотр : %dpx';
 TEXT_MES_NEW_DB_IMAGE_PANEL_PREVIEW = 'Изображения в панели : %dpx';

 TEXT_MES_SELECT_DB_FROM_LIST = 'Выбрать БД из списка';
 TEXT_MES_SELECT_FILE_ON_HARD_DISK = 'Выберите файл с диска';
 TEXT_MES_CHANGE_DB_OPTIONS = 'Изменить опции БД';
 TEXT_MES_CREATE_EXAMPLE_DB = 'Создать стандартную базу*';
 TEXT_MES_DB_DESCRIPTION = 'Описание базы';
 TEXT_MES_DB_PATH = 'Путь к базе';
 TEXT_MES_OPEN_FILE_LOCATION = 'Открыть месторасположение файла';
 TEXT_MES_CHANGE_FILE_LOCATION = 'Изменить расположение файла';
 TEXT_MES_PRESS_THIS_LINK_TO_CONVERT_DB = 'Для изменения размеров предпросмотров и качества запустите мастер конвертации базы';
 TEXT_MES_DB_CREATED_SUCCESS_F = 'База "%s" успешно создана';
 TEXT_MES_ADD_DEFAULT_GROUPS_TO_DB = 'Добавить стандартные группы';
 TEXT_MES_APPLICATION_PREV_FOUND_BUT_SEND_MES_FAILED = 'Запущена предыдущая копия приложения, но передача управления не удалась в течении 5 секунд! Запустить ещё одну копию приложения?';
 TEXT_MES_SHOW_FILE_IN_EXPLORER = 'Показать файл в проводнике';

 TEXT_MES_PROGRESS_FILL_COLOR = 'Цвет заливки прогресс-бара';
 TEXT_MES_PROGRESS_FONT_COLOR = 'Цвет шрифта прогресс-бара';
 TEXT_MES_PROGRESS_BACK_COLOR = 'Цвет фона прогресс-бара';

 TEXT_MES_USE_FULL_RECT_SELECT = 'Использовать полное выделение в списках';
 TEXT_MES_LIST_VIEW_ROUND_RECT_SIZE = 'Размер закругления:';
 TEXT_MES_SELECT_DB_AT_FIRST = 'Сперва выберите файл базы данных!';

 TEXT_MES_UNABLE_TO_RENAME_FILE_TO_FILE_F = 'Произошла ошибка при переименовании файла "%s" в "%s"!'#13'%s';
 TEXT_MES_DB_FILE_NOT_FOUND_ERROR = 'Файл базы не найдён при запуске приложения!'#13'Выберите другой файл или создайте новый.';

 TEXT_MES_VIEWER_REST_IN_MEMORY_CLOSE_Q = 'Просмотрщик остался запущенным, закрыть его?';

 TEXT_MES_LISENCE_FILE_BOT_FOUND = 'Файл с лицензионным соглашением не найден! Установка будет прекращена!';
 TEXT_MES_NO_RATING = 'Без оценки';
 TEXT_MES_IMAGES_NOT_FOUND_UPDATER_CLOSED = 'Изображения не найдены! Окно будет закрыто!';
 TEXT_MES_IMAGES_SORT_BY_COMPARE_RESULT = 'По похожести';
 TEXT_MES_ICON_OPTIONS = 'Настройки иконки';
 TEXT_MES_INTERNAL_NAME = 'Отображаемое имя';
 TEXT_MES_UNABLE_TO_FIND_PASS_FOR_FILE_F = 'Не удаётся найти пароь к файлу: "%s"';
 TEXT_MES_UNABLE_TO_ADD_FILE_F = 'Не удалось добавить файл: "%s"';
 TEXT_MES_FILE_NOT_EXISTS_F = 'Не найден файл "%s"';
 TEXT_MES_USE_SLIDE_SHOW_FAST_LOADING = 'Использовать быструю загрузку файлов (бд в фоне)';
 TEXT_MES_ERROR_ICONS_DLL = 'Не найдена библиотека icons.dll! Она содержит набор иконок для приложения, работа без этого файла невозможна!';
 TEXT_MES_SLIDE_PAGE_CATION = '   Страница %d из %d';
 TEXT_MES_DEFAULT_PROGRESS_TEXT = 'Прогресс... (&%%)';

 TEXT_MES_LOGIN_MODE_CAPTION = 'Режим входа в базу';
 TEXT_MES_LOGIN_MODE_USE_LOGIN = 'Использовать вход по имени\паролю';
 TEXT_MES_LOGIN_MODE_NO_LOGIN = 'НЕ использовать вход по имени\паролю, вход будет автоматический с максимальными правами';
 TEXT_MES_NO_LOGO = 'НЕТ лого';
 TEXT_MES_ERROR_CREATING_DEFAULT_USER_F = 'Произошла ошибка во время создания стандартного пользователя! Код ошибки %d';

 TEXT_MES_UPDATING_SYSTEM_INFO = 'Обновление системной информации...';
 
 TEXT_MES_CD_EXPORT_CAPTION = 'Экспорт фотографий на съёмный диск';
 TEXT_MES_CD_EXPORT_INFO = 'Данный диалог поможет Вам перенести часть фотографий, хранящихся на жёстком диске - на CD\DVD диск.'+' При этом информация о фотографиях останется в базе, а при необходимости просмотра фотографий программа попросит Вас вставить соответствующий диск.'#13'Программа не записывает данные на диск, а всего лишь формирует папку предназначенную для записи на диск.'+' Чтобы записать на диск данные файлы используйте специализированные программы!';
 TEXT_MES_CD_EXPORT_LABEL_DEFAULT = '?Имя диска';
 TEXT_MES_CREATE_CD_WITH_LABEL = 'Создать CD\DVD с меткой';
 TEXT_MES_ADD_CD_ITEMS = 'Добавить';
 TEXT_MES_REMOVE_CD_ITEMS = 'Удалить';
 TEXT_MES_CREATE_DIRECTORY = 'Создать директорию';
 TEXT_MES_CD_EXPORT_LIST_VIEW_LOCUMN_FILE_NAME = 'Имя файла'; 
 TEXT_MES_CD_EXPORT_LIST_VIEW_LOCUMN_FILE_SIZE = 'Размер';
 TEXT_MES_CD_EXPORT_LIST_VIEW_LOCUMN_DB_ID = 'ID из Базы';
 TEXT_MES_CD_EXPORT_DELETE_ORIGINAL_FILES = 'Удалить оригинальные файлы после удачного экспорта';
 TEXT_MES_CD_EXPORT_MODIFY_DB = 'Скорректировать информацию в БД после удачного экспорта';
 TEXT_MES_DO_CD_EXPORT = 'Экспортировать!';
 TEXT_MES_CD_EXPORT_DIRECTORY = 'Директория для экспорта';
 TEXT_MES_CHOOSE_DIRECTORY = 'Выбрать директорию';
 TEXT_MES_CD_EXPORT_SIZE = 'Размер файлов для экспорта';
 TEXT_MES_SELECT_PLACE_TO_CD_EXPORT = 'Выберите папку для экспорта файлов';
 TEXT_MES_ENTER_NEW_VIRTUAL_DIRECTORY_NAME = 'Введите имя для новой директории';
 TEXT_MES_ENTER_CD_LABEL_TO_IDENTIFY_DISK = 'Пожалуйста, введите метку диска которая уникально определит диск!'#13'В названии нельзя использовать символы ":","\" и "?"';
 TEXT_MES_CD_EXPORT_HASNT_ANY_DB_FILE = 'Экспортируемые данные не имеют ни одного файла, связанного с текущей базой данных! Возможно Вы не выбрали нужную базу! Продолжать экспорт?';
 TEXT_MES_CD_EXPORT_OK_F = 'Файлы для записи на диск успешно экспортированы в папку "%s"!';
 TEXT_MES_UNABLE_TO_COPY_DISK_FULL_F = 'Невозмоно скопировать файлы, т.к. обнаружено недостаточное количество свободного места на диске! Необходимо %s, а свободно %s!';
 TEXT_MES_UNABLE_TO_COPY_DISK = 'Невозможно скопировать файлы в конечное рамещение! Проверьте, имеются ли права записи в указанную директорию!';
 TEXT_MES_UNABLE_TO_DELETE_ORIGINAL_FILES = 'Не удалось удалить оригинальные файлы! Проверьте, имеете ли Вы право на удаление файлов. Попробуйте позже вручную удалить эти файлы.';

 TEXT_MES_CD_MAPPING_CAPTION = 'Привязка дисков';
 TEXT_MES_CD_MAP_FILE = 'DBCDMap.map';
 TEXT_MES_CD_LOCATION = 'Размещение диска';
 TEXT_MES_CD_MOUNED_PERMANENT = 'Привязан';
 TEXT_MES_REMOVE_CD_LOCATION = 'Отвязать диск от файлов';
 TEXT_MES_ADD_CD_LOCATION = 'Связать диск с базой';

 TEXT_MES_UNABLE_TO_FIND_FILE_CDMAP_F = 'Не удалось найти файл '+TEXT_MES_CD_MAP_FILE+' по адресу "%s"';
 TEXT_MES_CD_DVD_SELECT = 'Выбрать диск';
 TEXT_MES_CD_MAPPING_INFO = 'В этом окне Вы можете указать размещение фисков с фотографиями, для этого укажите корневую папку с файлами конкретного диска или укажите файл '+TEXT_MES_CD_MAP_FILE;
 TEXT_MES_CD_MAP_QUESTION_CAPTION = 'Привязка диска';
 TEXT_MES_CD_MAP_QUESTION_INFO_F = 'Вы выбрали для просмотра файл, который находится на съёмном носителе (к примеру, CD\DVD)'+#13+'Вставьте, пожалуйста, диск с фотографиями с меткой "%s" и выберите пункт "'+TEXT_MES_CD_DVD_SELECT+'" для определения местонахождения файлов.'+#13+'Вы можете указать как директорию с файлами, так и файл '+TEXT_MES_CD_MAP_FILE+' на диске.';
 TEXT_MES_DONT_ASK_ME_AGAIN = 'Не спрашивать более';
 TEXT_MES_DISK = 'Диск';
 TEXT_MES_LOADED_DIFFERENT_DISK_F = 'Был загружен диск с меткой "%s", а требуется диск с меткой "%s"! Вы хотите закрыть этот диалог?';
 TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE = 'Нельзя использовать для даной операции файл, находящийся на диске! Скопируйте файл в другое место или выберите другой файл.';
 TEXT_MES_EXPLORER_CD_DVD = 'Открыть съёмный диск';
 TEXT_MES_REFRESH_DB_FILES_ON_CD = 'Обновить записи в базе для данного диска';


 TEXT_MES_GO_BACK = 'Перейти назад';
 TEXT_MES_GO_FORWARD = 'Перейти вперёд';
 TEXT_MES_GO_UP = 'Перейти на уровень выше';

 TEXT_MES_MENU_RELOADED = 'Скрипт меню успешно перегружен!';

 TEXT_MES_UNABLE_TO_FIND_FILE_CDMAP_IN_FOLDER_USE_IT_F = 'В этой папке не найден файл '+TEXT_MES_CD_MAP_FILE+'! Всё равно использовать данную папку как корневой каталог диска "%s"?';
 TEXT_MES_USE_SMALL_TOOLBAR_ICONS = 'Ипользовать маленькие иконки для тубларов';
 TEXT_MES_CREATE_PORTABLE_DB = 'Создать портабельную базу данных на диске';

 TEXT_MES_ICONS_OPEN_MASK = 'Все поддерживаемые форматы|*.exe;*.ico;*.dll;*.ocx;*.scr|Иконки (*.ico)|*.ico|Исполняемые файлы (*.exe)|*.exe|Dll файлы (*.dll)|*.dll';

  implementation

end.
