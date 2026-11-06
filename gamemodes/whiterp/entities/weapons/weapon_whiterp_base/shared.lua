SWEP.Base = "weapon_base"
SWEP.PrintName = "WhiteRP Weapon Base"
SWEP.Author = "WhiteRP"
SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.UseHands = true
SWEP.ViewModelFOV = 62
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "pistol"
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 36
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Delay = 0.22
SWEP.Primary.Damage = 18
SWEP.Primary.Force = 3
SWEP.Primary.Spread = 0.018
SWEP.Primary.Range = 8192
SWEP.Primary.Tracer = 1
SWEP.Primary.Sound = "Weapon_Pistol.Single"
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ReloadTime = 1.35
SWEP.Recoil = 0.7
SWEP.IronSightsPos = Vector(-5.5, -4, 2)
SWEP.IronSightsAng = Angle(0, 0, 0)

function SWEP:Initialize()
    self:SetHoldType(self.HoldType or "pistol")
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:SetNextPrimaryFire(CurTime() + (self.Primary.Delay or 0.22))
    if self:Clip1() <= 0 then
        self:EmitSound("Weapon_Pistol.Empty")
        self:SetNextPrimaryFire(CurTime() + 0.3)
        return
    end

    self:TakePrimaryAmmo(1)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    owner:SetAnimation(PLAYER_ATTACK1)
    self:EmitSound(self.Primary.Sound or "Weapon_Pistol.Single", 75, 100, 1, CHAN_WEAPON)

    if SERVER then
        owner:LagCompensation(true)
        owner:FireBullets({
            Num = 1,
            Src = owner:GetShootPos(),
            Dir = owner:GetAimVector(),
            Spread = Vector(self.Primary.Spread or 0.018, self.Primary.Spread or 0.018, 0),
            Distance = self.Primary.Range or 8192,
            Tracer = self.Primary.Tracer or 1,
            Force = self.Primary.Force or 3,
            Damage = self.Primary.Damage or 18,
            AmmoType = self.Primary.Ammo
        })
        owner:LagCompensation(false)
        owner:ViewPunch(Angle(-math.Rand(0.35, self.Recoil or 0.7), math.Rand(-0.18, 0.18), 0))
    end

    if CLIENT then
        local vm = owner:GetViewModel()
        if IsValid(vm) then
            local effect = EffectData()
            effect:SetEntity(vm)
            effect:SetAttachment(1)
            util.Effect("MuzzleFlash", effect)
        end
    end
end

function SWEP:Reload()
    if self:Clip1() >= self.Primary.ClipSize or self:Ammo1() <= 0 then return end
    self:SetNextPrimaryFire(CurTime() + (self.ReloadTime or 1.35))
    self:DefaultReload(ACT_VM_RELOAD)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.25)
    if CLIENT then self.IronSights = not self.IronSights end
end

if CLIENT then
    function SWEP:GetViewModelPosition(pos, ang)
        self.IronSightsAmount = Lerp(math.min(FrameTime() * 12, 1), self.IronSightsAmount or 0, self.IronSights and 1 or 0)
        local amount = self.IronSightsAmount
        local targetPos = self.IronSightsPos or vector_origin
        local targetAng = self.IronSightsAng or angle_zero
        pos = pos + ang:Forward() * targetPos.x * amount + ang:Right() * targetPos.y * amount + ang:Up() * targetPos.z * amount
        ang:RotateAroundAxis(ang:Right(), targetAng.p * amount)
        ang:RotateAroundAxis(ang:Up(), targetAng.y * amount)
        ang:RotateAroundAxis(ang:Forward(), targetAng.r * amount)
        return pos, ang
    end

    function SWEP:TranslateFOV(fov)
        return fov - (self.IronSights and 8 or 0)
    end
end

function SWEP:ShouldDropOnDie()
    return false
end
