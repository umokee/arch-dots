return {
	"Weyaaron/nvim-training",
	pin = true, -- Фиксируем версию для стабильности
	opts = {
		-- Аудио-фидбек (нужен sox с play в PATH)
		audio_feedback = true,

		-- Границы счётчиков (не больше 5, чтоб не глючило)
		counter_bounds = { 1, 5 },

		-- Кастомные коллекции задач (добавь свои)
		custom_collections = {
			MyMotions = { "MoveWord", "Movef", "MoveF" },
			Changes = { "ChangeLine", "ChangeWORD" },
		},

		-- Отключаем treesitter-задачи по дефолту (нужен treesitter-setup)
		disabled_tags = { "treesitter" },
		disabled_collections = { "Treesitter-Tasks" },

		-- Включаем счётчики и репиты на фейл
		enable_counters = true,
		enable_repeat_on_failure = true,

		-- Хайлайты для задач (удобно)
		enable_highlights = true,

		-- Регистры выключаем (чтоб не усложнять)
		enable_registers = false,

		-- Логи (опционально)
		logging_args = {
			enable_logging = true,
			display_warnings = true,
			display_logs = false, -- Много спама
		},

		-- Марки и регистры (маленький набор)
		possible_marks_list = { "a", "b", "c", "r" },
		possible_register_list = { "a", "b", "c" },

		-- Счётчик повторов для шедулеров
		scheduler_args = { repetitions = 5 },

		-- Алфавит для f/t/F/T (без спецсимволов)
		task_alphabet = "abcdefgijkmnopqrstuvwxz",
	},
	keys = {
		-- Горячие клавиши для быстрого старта (опционально)
		{ "<leader>tt", "<cmd>Training Start RandomScheduler Movement Word</cmd>", desc = "Training: Motions" },
		{ "<leader>ta", "<cmd>Training Analyze</cmd>", desc = "Training: Analyze" },
		{ "<leader>ts", "<cmd>Training Stop</cmd>", desc = "Training: Stop" },
	},
}
