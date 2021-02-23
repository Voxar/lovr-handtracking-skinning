local lovr = lovr

function lovr.load()
  model = lovr.graphics.newModel('female_hand_rig.glb')

  shader = lovr.graphics.newShader('standard', {
    flags = {
  		animated = true,
      normalMap = true,
	    normalTexture = true,
      indirectLighting = true,
      occlusion = true,
      emissive = true,
      skipTonemap = false,
    }
  })

  skybox = lovr.graphics.newTexture({
    left = 'env/nx.png',
    right = 'env/px.png',
    top = 'env/py.png',
    bottom = 'env/ny.png',
    back = 'env/pz.png',
    front = 'env/nz.png'
  }, { linear = true })

  environmentMap = lovr.graphics.newTexture(256, 256, { type = 'cube' })
  for mipmap = 1, environmentMap:getMipmapCount() do
    for face, dir in ipairs({ 'px', 'nx', 'py', 'ny', 'pz', 'nz' }) do
      local filename = ('env/m%d_%s.png'):format(mipmap - 1, dir)
      local image = lovr.data.newTextureData(filename, false)
      environmentMap:replacePixels(image, 0, 0, face, mipmap)
    end
  end

  shader:send('lovrLightDirection', { -1, -1, -1 })
  shader:send('lovrLightColor', { .9, .9, .8, 1.0 })
  shader:send('lovrExposure', 2)
  shader:send('lovrSphericalHarmonics', require('env/sphericalHarmonics'))
  shader:send('lovrEnvironmentMap', environmentMap)

  lovr.graphics.setBackgroundColor(.18, .18, .20)
  lovr.graphics.setCullingEnabled(true)
  -- lovr.graphics.setBlendMode()
  
  print("joints", model:hasJoints())
  print("joint count", model:getNodeCount()) 

  for i = 1, model:getNodeCount() do
    print(i, model:getNodeName(i))
    -- print(model:getNodePose(i))
  end
end


local fingermap = {
  --1  fml_shirt_R
--2  handL_low
[2] = 3,--  wrist
[22] = 4,--  little_metacarpal
[23] = 5,--  little_proximal
[24] = 6,--  little_intermediate
[25] = 7,--  little_distal
[26] = 8,--  little_tip
[17] = 9,--  ring_metacarpal
[18] = 10,--  ring_proximal
[19] = 11,--  ring_intermediate
[20] = 12,--  ring_distal
[21] = 13,--  ring_tip
[12] = 14,--  middle_metacarpal
[13] = 15,--  middle_proximal
[14] = 16,--  middle_intermediate
[15] = 17,--  middle_distal
[16] = 18,--  middle_tip
[7] = 19,--  index_metacarpal
[8] = 20,--  index_proximal
[9] = 21,--  index_intermediate
[10] = 22,--  index_distal
[11] = 23,--  index_tip
[3] = 24,--  thumb_metacarpal
[4] = 25,--  thumb_proximal
[5] = 26,--  thumb_distal
[6] = 27,--  thumb_tip
[1] = 28,--  palm
-- 29  nil

}

function parent_node(i)
  
  if i == 1 then
    -- palm
    return 2
  elseif i == 2 then
    -- wrist
    return 0
  elseif i == 3 then
    -- thumb Metacarpal
    return 1
  elseif i == 4 then
    -- thumb Proximal
    return i-1
  elseif i == 5 then
    -- thumb Distal
    return i-1
  elseif i == 6 then
    -- thumb Tip
    return i-1
  elseif i == 7 then 
    -- index Metacarpal
    return 2
  elseif i == 8 then 
    -- index Proximal
    return i-1
  elseif i == 9 then 
    -- index Intermediate
    return i-1
  elseif i == 10 then 
    -- index Distal
    return i-1
  elseif i == 11 then 
    -- index Tip
    return i-1
  elseif i == 12 then 
    -- middle Metacarpal
    return 2
  elseif i == 13 then 
    -- middle Proximal
    return i-1
  elseif i == 14 then 
    -- middle Intermediate
    return i-1
  elseif i == 15 then 
    -- middle Distal
    return i-1
  elseif i == 16 then 
    -- middle Tip
    return i-1
  elseif i == 17 then   
    -- ring Metacarpal
    return 2
  elseif i == 18 then 
    -- ring Proximal
    return i-1
  elseif i == 19 then 
    -- ring Intermediate
    return i-1
  elseif i == 20 then 
    -- ring Distal
    return i-1
  elseif i == 21 then 
    -- ring Tip
    return i-1
  elseif i == 22 then   
    -- pinky Metacarpal
    return 2
  elseif i == 23 then 
    -- pinky Proximal
    return i-1
  elseif i == 24 then 
    -- pinky Intermediate
    return i-1
  elseif i == 25 then 
    -- pinky Distal
    return i-1
  elseif i == 26 then 
    -- pinky Tip
    return i-1
  end
end
local vec3 = lovr.math.vec3
local mat4 = lovr.math.mat4
local quat = lovr.math.quat

local cache = {}
function lovr.draw()
  lovr.graphics.setColor(1, 1, 1)
  -- lovr.graphics.translate(0,0,-1)
  lovr.graphics.skybox(skybox)
  lovr.graphics.setShader(shader)
  -- model:draw(0, 1.5, -1, 1, 1)
  -- lovr.graphics.setShader()
  lovr.graphics.sphere(0,0,0, 0.01)

  lovr.graphics.setPointSize(10)
  for _, hand in ipairs({ 'left', 'right' }) do
    for i, joint in ipairs(lovr.headset.getSkeleton(hand) or {}) do
      lovr.graphics.print(tostring(i), joint[1], joint[2], joint[3], 0.03, joint[4], joint[5], joint[6], joint[7])
      lovr.graphics.points(unpack(joint, 1, 3))
    end
  end

  function dir(t)
    for k,v in pairs(t) do
      print(k, v)
    end
  end


  function mat(joint)
    return lovr.math.mat4(vec3(unpack(joint, 1, 3)), vec3(1,1,1), quat(unpack(joint, 4, 7)))
    -- return lovr.math.mat4(vec3(unpack(joint, 1, 3)), vec3(1,1,1), quat())
  end

  model:pose()

  local skeleton = lovr.headset.getSkeleton('left') or {}
  local hx, hy, hz, ha, hax, hay, haz = vec3(lovr.headset.getPose('left'))
  local handPosition = vec3(hx, hy, hz)
  local handRotation = quat(ha, hax, hay, haz):conjugate()

  for i, joint in ipairs(skeleton) do
    if i == 1 or i == 2 then
      if i == 1 then 
        handPosition = lovr.math.newVec3(unpack(joint, 1, 3))
        handRotation = lovr.math.newQuat(quat(unpack(joint, 4, 7)):conjugate())
      end
      -- joint.worldPosition = lovr.math.newVec3(vec3(unpack(joint, 1, 3)):sub(handPosition))
      -- joint.worldRotation = lovr.math.newQuat(quat(unpack(joint, 4, 7)):mul(handRotation))

      joint.worldPosition = lovr.math.newVec3(vec3(unpack(joint, 1, 3)):sub(handPosition))
      joint.worldRotation = lovr.math.newQuat(quat(unpack(joint, 4, 7)):mul(handRotation))
    
      joint.position = lovr.math.newVec3()
      joint.rotation = lovr.math.newQuat()
    else
      joint.worldPosition = lovr.math.newVec3(vec3(unpack(joint, 1, 3)):sub(handPosition))
      joint.worldRotation = lovr.math.newQuat(quat(unpack(joint, 4, 7)):mul(handRotation))

      local parent_i = parent_node(i)
      local pos = vec3(joint.worldPosition)
      local rot = quat(joint.worldRotation)
      while parent_i > 0 do
        local parent = skeleton[parent_i]
        -- pos = parent.pos + (pos - parent.pos) * parent.inv_rot
        -- pos = parent.inv_rot * (pos - parent.pos) + parent.pos
        pos = quat(parent.rotation):conjugate():mul(vec3(pos):sub(parent.worldPosition)):add(parent.position)
        -- rot = rot - parent.rot
        rot = rot:mul(quat(parent.rotation):conjugate())
        parent_i = parent_node(parent_i)
      end
      parent_i = parent_node(i)
      local parent = skeleton[parent_i]
      joint.position = lovr.math.newVec3(pos:sub(parent.position))
      joint.rotation = lovr.math.newQuat(rot)
    end
    local x, y, z = joint.position:unpack()
    local a, ax, ay, az = joint.rotation:unpack()

    model:pose(fingermap[i], x, y, z, a, ax, ay, az)

  end

  lovr.graphics.translate(handPosition)
  lovr.graphics.rotate(handRotation:conjugate())
  

  lovr.graphics.setColor(1,1,1)
  for i = 1, model:getNodeCount() do
    local x, y, z, a, ax, ay, az = model:getNodePose(i)
    lovr.graphics.sphere(x, y, z, 0.01)
    lovr.graphics.print(tostring(i), x, y, z, 0.03, a, ax, ay, az)
  end
  lovr.graphics.setColor(1,1,1,0.3)

  model:draw()
 
  -- lovr.graphics.pop()
end
