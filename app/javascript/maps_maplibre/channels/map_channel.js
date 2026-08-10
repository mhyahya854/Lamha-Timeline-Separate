import consumer from "../../channels/consumer"

/**
 * Create map channel subscription for maps_maplibre
 * Creates real-time update subscriptions for the map
 * @param {Object} options - { received, connected, disconnected, enableLiveMode }
 * @returns {Object} Subscriptions object with multiple channels
 */
export function createMapChannel(options = {}) {
  const { enableLiveMode = false, ...callbacks } = options
  const subscriptions = {
    points: null,
    tracks: null,
  }

  console.log(
    "[MapChannel] Creating channels with enableLiveMode:",
    enableLiveMode,
  )

  // Defensive check - consumer might not be available
  if (!consumer) {
    console.warn("[MapChannel] ActionCable consumer not available")
    return {
      subscriptions,
      unsubscribeAll() {},
    }
  }

  // Subscribe to points channel for real-time point updates (only if live mode is enabled)
  if (enableLiveMode) {
    try {
      subscriptions.points = consumer.subscriptions.create("PointsChannel", {
        connected() {
          console.log("PointsChannel connected")
          callbacks.connected?.("points")
        },

        disconnected() {
          console.log("PointsChannel disconnected")
          callbacks.disconnected?.("points")
        },

        received(data) {
          console.log("PointsChannel received:", data)
          callbacks.received?.({
            type: "new_point",
            point: data,
          })
        },
      })
    } catch (error) {
      console.warn("[MapChannel] Failed to subscribe to points channel:", error)
    }
  } else {
    console.log(
      "[MapChannel] Live mode disabled, not subscribing to PointsChannel",
    )
  }

  // Note: NotificationsChannel is handled by notifications_controller.js in the navbar
  // Creating a second subscription here causes issues with ActionCable

  // Subscribe to tracks channel for real-time track updates
  try {
    subscriptions.tracks = consumer.subscriptions.create("TracksChannel", {
      connected() {
        console.log("TracksChannel connected")
        callbacks.connected?.("tracks")
      },

      disconnected() {
        console.log("TracksChannel disconnected")
        callbacks.disconnected?.("tracks")
      },

      received(data) {
        console.log("TracksChannel received:", data)
        callbacks.received?.({
          type: "track_update",
          action: data.action,
          track: data.track,
          track_id: data.track_id,
        })
      },
    })
  } catch (error) {
    console.warn("[MapChannel] Failed to subscribe to tracks channel:", error)
  }

  return {
    subscriptions,
    unsubscribeAll() {
      Object.values(subscriptions).forEach((sub) => {
        sub?.unsubscribe()
      })
    },
  }
}
