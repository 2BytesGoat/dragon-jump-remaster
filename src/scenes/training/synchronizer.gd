extends Node

const MAJOR_VERSION := "0"
const MINOR_VERSION := "7"
const DEFAULT_PORT := "11008"
const DEFAULT_SEED := "1"
var stream: StreamPeerTCP = null
var connected = false
var message_center
var should_connect = true

@export_range(1, 10, 1, "or_greater") var action_repeat := 8

var args = {} # TODO: this needs to be set from outside
var agents_training: Array = []

var _action_space_training: Array[Dictionary] = []
var _obs_space_training: Array[Dictionary] = []

var initialized := false
var n_action_steps := 0
var just_reset := false
var need_to_send_obs := false


func initialize() -> void:
	get_tree().set_pause(true)
	# TODO: add a way to change this speed
	#Engine.physics_ticks_per_second = _get_speedup() * 60  # Replace with function body.
	#Engine.time_scale = _get_speedup() * 1.0
	
	# Initialize training agents
	agents_training = get_agents()
	_initialize_training_agents()
	
	# Set training vars
	_set_seed()
	_set_action_repeat()
	initialized = true
	
	await get_tree().create_timer(1.0).timeout
	get_tree().set_pause(false)

func _physics_process(_delta):
	if n_action_steps % action_repeat != 0:
		n_action_steps += 1
		return

	n_action_steps += 1

	training_process()


func _initialize_training_agents():
	if agents_training.size() > 0:
		_obs_space_training.resize(agents_training.size())
		_action_space_training.resize(agents_training.size())
		for agent_idx in range(0, agents_training.size()):
			_obs_space_training[agent_idx] = agents_training[agent_idx].get_obs_space()
			_action_space_training[agent_idx] = agents_training[agent_idx].get_action_space()
		connected = connect_to_server()
		if connected:
			_handshake()
			send_env_info()
		else:
			push_warning(
				"Couldn't connect to Python server, using human controls instead. ",
				"Did you start the training server using e.g. `gdrl` from the console?"
			)


func get_agents() -> Array:
	return get_tree().get_nodes_in_group("AGENT")


func connect_to_server():
	print("Waiting for one second to allow server to start")
	OS.delay_msec(1000)
	print("trying to connect to server")
	stream = StreamPeerTCP.new()

	# "localhost" was not working on windows VM, had to use the IP
	var ip = "127.0.0.1"
	var port = _get_port()
	var connect = stream.connect_to_host(ip, port)
	stream.set_no_delay(true)  # TODO check if this improves performance or not
	stream.poll()
	# Fetch the status until it is either connected (2) or failed to connect (3)
	while stream.get_status() < 2:
		stream.poll()
	return stream.get_status() == 2


func send_env_info():
	var json_dict = _get_dict_json_message()
	assert(json_dict["type"] == "env_info")

	var message = {
		"type": "env_info",
		"observation_space": _obs_space_training,
		"action_space": _action_space_training,
		"n_agents": len(agents_training),
		#"agent_policy_names": agents_training_policy_names
	}
	_send_dict_as_json_message(message)


func training_process():
	if connected:
		get_tree().set_pause(true)

		var obs = _get_obs_from_agents(agents_training)
		var info = _get_info_from_agents(agents_training)

		if just_reset:
			just_reset = false

			var reply = {"type": "reset", "obs": obs, "info": info}
			_send_dict_as_json_message(reply)
			# this should go straight to getting the action and setting it checked the agent, no need to perform one phyics tick
			get_tree().set_pause(false)
			return

		if need_to_send_obs:
			need_to_send_obs = false
			var reward = _get_reward_from_agents()
			var done = _get_done_from_agents()
			#_reset_agents_if_done() # this ensures the new observation is from the next env instance : NEEDS REFACTOR

			var reply = {"type": "step", "obs": obs, "reward": reward, "done": done, "info": info}
			_send_dict_as_json_message(reply)

		var handled = handle_message()


func _handshake():
	print("performing handshake")

	var json_dict = _get_dict_json_message()
	assert(json_dict["type"] == "handshake")
	var major_version = json_dict["major_version"]
	var minor_version = json_dict["minor_version"]
	if major_version != MAJOR_VERSION:
		print("WARNING: major verison mismatch ", major_version, " ", MAJOR_VERSION)
	if minor_version != MINOR_VERSION:
		print("WARNING: minor verison mismatch ", minor_version, " ", MINOR_VERSION)

	print("handshake complete")


func _get_dict_json_message():
	# returns a dictionary from of the most recent message
	# this is not waiting
	while stream.get_available_bytes() == 0:
		stream.poll()
		if stream.get_status() != 2:
			print("server disconnected status, closing")
			get_tree().quit()
			return null

		OS.delay_usec(10)

	var message = stream.get_string()
	var json_data = JSON.parse_string(message)

	return json_data


func _send_dict_as_json_message(dict):
	stream.put_string(JSON.stringify(dict, "", false))


func _get_obs_from_agents(agents: Array):
	var obs = []
	for agent in agents:
		obs.append(agent.get_obs())
	return obs


func _get_reward_from_agents(agents: Array = agents_training):
	var rewards = []
	for agent in agents:
		rewards.append(agent.get_reward())
		agent.zero_reward()
	return rewards


func _get_info_from_agents(agents: Array):
	var info = []
	for agent in agents:
		info.append(agent.get_info())
	return info


func _get_done_from_agents(agents: Array = agents_training):
	var dones = []
	for agent in agents:
		var done = agent.get_done()
		if done:
			agent.set_done_false()
		dones.append(done)
	return dones


func _set_agent_actions(actions, agents: Array):
	for i in range(len(actions)):
		agents[i].set_action(actions[i])


func _reset_agents(agents = agents_training):
	for agent in agents:
		agent.reset()


func _get_port():
	return args.get("port", DEFAULT_PORT).to_int()


func _set_seed():
	var _seed = args.get("env_seed", DEFAULT_SEED).to_int()
	seed(_seed)


func _set_action_repeat():
	action_repeat = args.get("action_repeat", str(action_repeat)).to_int()


func handle_message() -> bool:
	# get json message: reset, step, close
	var message = _get_dict_json_message()
	if message["type"] == "close":
		print("received close message, closing game")
		get_tree().quit()
		get_tree().set_pause(false)
		return true

	if message["type"] == "reset":
		print("resetting all agents")
		_reset_agents()
		just_reset = true
		get_tree().set_pause(false)
		#print("resetting forcing draw")
#        RenderingServer.force_draw()
#        var obs = _get_obs_from_agents()
#        print("obs ", obs)
#        var reply = {
#            "type": "reset",
#            "obs": obs
#        }
#        _send_dict_as_json_message(reply)
		return true

	#if message["type"] == "call":
		#var method = message["method"]
		#var returns = _call_method_on_agents(method)
		#var reply = {"type": "call", "returns": returns}
		#print("calling method from Python")
		#_send_dict_as_json_message(reply)
		#return handle_message()

	if message["type"] == "action":
		var action = message["action"]
		_set_agent_actions(action, agents_training)
		need_to_send_obs = true
		get_tree().set_pause(false)
		return true

	print("message was not handled")
	return false
