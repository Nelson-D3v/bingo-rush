## Bus central de sinais. Os sinais são emitidos por outros módulos via GameEvents.signal.emit()
extends Node

# --- Fluxo do jogo ---
@warning_ignore("unused_signal") signal game_state_changed(new_state: String)
@warning_ignore("unused_signal") signal round_started()
@warning_ignore("unused_signal") signal round_ended(won: bool)

# --- Seleção de cartelas (fase pré-jogo, gratuita) ---
@warning_ignore("unused_signal") signal cards_prepared(count: int)
@warning_ignore("unused_signal") signal card_swap_requested(card_id: int)
@warning_ignore("unused_signal") signal card_swapped(card_id: int)

# --- Sorteio ---
@warning_ignore("unused_signal") signal number_drawn(number: int)
@warning_ignore("unused_signal") signal draw_sequence_complete()
@warning_ignore("unused_signal") signal extra_ball_drawn(number: int)
@warning_ignore("unused_signal") signal turbo_mode_activated()

# --- Cartelas ---
@warning_ignore("unused_signal") signal cards_purchased(count: int, cost: int)
@warning_ignore("unused_signal") signal card_number_marked(card_id: int, number: int, cell_index: int)

# --- Padrões ---
@warning_ignore("unused_signal") signal pattern_completed(card_id: int, pattern_id: String, reward: int)
@warning_ignore("unused_signal") signal near_win_detected(card_id: int, pattern_id: String, numbers_away: int)

# --- Bolas extras ---
@warning_ignore("unused_signal") signal extra_ball_offered(cost: int, numbers_away: int)
@warning_ignore("unused_signal") signal extra_ball_purchased(cost: int)
@warning_ignore("unused_signal") signal extra_ball_declined()

# --- Economia ---
@warning_ignore("unused_signal") signal coins_changed(new_balance: int, delta: int)
@warning_ignore("unused_signal") signal reward_granted(amount: int, reason: String)
@warning_ignore("unused_signal") signal insufficient_funds()

# --- Progressão ---
@warning_ignore("unused_signal") signal xp_gained(amount: int, new_total: int)
@warning_ignore("unused_signal") signal level_up(new_level: int)
@warning_ignore("unused_signal") signal achievement_unlocked(achievement_id: String)

# --- Eventos especiais ---
@warning_ignore("unused_signal") signal special_event_triggered(event_type: String)
@warning_ignore("unused_signal") signal multiplier_activated(multiplier: float)
@warning_ignore("unused_signal") signal bonus_ball_triggered()
