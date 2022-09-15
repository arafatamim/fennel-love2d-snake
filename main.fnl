(var timer 0)
(var cell-size 15)
(var snake-segments [])
(var direction :right)
(var grid-x-count 20)
(var grid-y-count 15)
(var food-position {:x 0 :y 0})

(fn randomize-food []
  (set food-position
       {:x (love.math.random 1 grid-x-count)
        :y (love.math.random 1 grid-y-count)}))

(fn draw-cell [x y]
  (love.graphics.rectangle :fill (* (- x 1) cell-size) (* (- y 1) cell-size)
                           (- cell-size 1) (- cell-size 1)))

(love.window.setMode (* grid-x-count cell-size) (* grid-y-count cell-size) {})

(fn love.load []
  (set timer 0)
  (set snake-segments [{:x 3 :y 1} {:x 2 :y 1} {:x 1 :y 1}])
  (randomize-food))

(fn love.draw []
  (love.graphics.setColor 0.28 0.28 0.28)
  (love.graphics.rectangle :fill 0 0 (* grid-x-count cell-size)
                           (* grid-y-count cell-size))
  "Draw snake"
  (each [i segment (ipairs snake-segments)]
    (love.graphics.setColor 0.6 1 0.32)
    (draw-cell segment.x segment.y))
  "Draw food"
  (love.graphics.setColor 1 0.3 0.3)
  (draw-cell food-position.x food-position.y))

(fn love.update [dt]
  (set timer (+ timer dt))
  (when (>= timer 0.15)
    (set timer 0)
    (local snake-head (. snake-segments 1))
    (local (next-x-position next-y-position)
           (unpack (match direction
                     :right [(if (> snake-head.x grid-x-count) 1
                                 (+ snake-head.x 1))
                             snake-head.y]
                     :left [(if (< snake-head.x 1)
                                grid-x-count
                                (- snake-head.x 1))
                            snake-head.y]
                     :down [snake-head.x
                            (if (> snake-head.y grid-y-count) 1
                                (+ snake-head.y 1))]
                     :up [snake-head.x
                          (if (< snake-head.y 1)
                              grid-y-count
                              (- snake-head.y 1))])))
    (var can-move? true)
    (each [i segment (ipairs snake-segments)]
      (when (and (not= i (length snake-segments)) (= next-x-position segment.x)
                 (= next-y-position segment.y))
        (set can-move? false)))
    (if can-move?
        (do
          (table.insert snake-segments 1
                        {:x next-x-position :y next-y-position})
          (if (and (= snake-head.x food-position.x)
                   (= snake-head.y food-position.y))
              (randomize-food)
              (table.remove snake-segments)))
        (love.load))))

(fn love.keypressed [key]
  (set direction (match key
                   (where :right (not= direction :left)) :right
                   (where :left (not= direction :right)) :left
                   (where :down (not= direction :up)) :down
                   (where :up (not= direction :down)) :up
                   _ direction)))
