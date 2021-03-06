# _______CHANGE BELOW THIS_______

# Player Character Stats
Health = OVALMYHEALTH
Accuracy = OVALMYACC
Defense = OVALMYDEF
Melee = OVALMYMELEE
Ranging = OVALMYRANGE
Psychic = OVALMYPSY

# Player Armor/Weapon Stats
Type = OVALMYTYPE # Use "M"/"R"/"P" for Melee, Ranging, Psychic respectively
HitMax = OVALMYMAX
HitMin = OVALMYMIN
AttackSpeed = OVALMYSPEED # Attack Speed in ticks (Seconds*2)
MeleeDefense = OVALMYMELEEDEF
RangingDefense = OVALMYRANGEDEF
PsychicDefense = OVALMYPSYDEF
MeleeAccuracy = OVALMYMELEEACC
RangingAccuracy = OVALMYRANGEACC
PsychicAccuracy = OVALMYPSYACC

# Healing Stats
HealingAmount = OVALMYHEALAMT
HealingQuantity = OVALMYHEALQUANT # Number of food brought per trip

# Enemy Stats
E.CombatLevel = MILFMYCBTLVL # Use 0 if you don't want xp stats
E.Type = MILFMYTYPE # Use "M"/"R"/"P" for Melee, Ranging, Psychic respectively
E.Health = MILFMYHEALTH
E.HitMax = MILFMYMAX
E.AttackSpeed = MILFMYSPEED # Use 2 for Zenitsu. Otherwise use 4
E.Accuracy = MILFMYACC
E.Defense = MILFMYDEF
E.Melee = MILFMYMELEE
E.Ranging = MILFMYRANGE
E.Psychic = MILFMYPSY

# Area Status
Toxic = GOOBY # Use 'T' if on Punk Hazard without a Hazmat, otherwise use 'F'



# _______DO NOT CHANGE BELOW THIS_______
# Code

if(Type == "M"){
  primarystat <- Melee
  TrueAccuracy <- Accuracy + MeleeAccuracy
  E.secondarystat <- E.Melee
} else if(Type == "R"){
  primarystat <- Ranging
  TrueAccuracy <-Accuracy + RangingAccuracy
  E.secondarystat <- E.Ranging
} else if(Type == "P"){
  primarystat <- Psychic
  TrueAccuracy <- Accuracy + PsychicAccuracy
  E.secondarystat <- E.Psychic
}

if(E.Type == "M"){
  E.primarystat <- E.Melee
  secondarystat <- Melee
  trueDef <- Defense + MeleeDefense
} else if(E.Type == "R"){
  E.primarystat <- E.Ranging
  secondarystat <- Ranging
  trueDef <- Defense + RangingDefense
} else if(E.Type == "P"){
  E.primarystat <- E.Psychic
  secondarystat <- Psychic
  trueDef <- Defense + PsychicDefense
}


hitprob <- (TrueAccuracy + (primarystat/4))/(TrueAccuracy + E.Defense + (primarystat/4) + (E.secondarystat/4))
E.hitprob <- (E.Accuracy + (E.primarystat/4))/(E.Accuracy + trueDef + (E.primarystat/4) + (secondarystat/4))


SimulateFights <- function(n){
  Win <- 0
  fights <- 0
  while(n > fights){
    FtickW <- 0
    rawtickW <- 0
    tickL <- 0
    HealthNew <- Health
    E.HealthNew <- E.Health
    HealingQuantityNew <- HealingQuantity
    while(E.HealthNew > 0){
      PlayerRoll <- rbinom(1,1,hitprob)
      if(PlayerRoll == 1){
        E.HealthNew <- E.HealthNew - sample(HitMin:HitMax,1)
        rawtickW <- rawtickW + 1
      } else if(PlayerRoll == 0){
        rawtickW <- rawtickW + 1
      }
      rawtickW <- rawtickW + AttackSpeed - 1
    }
    while(HealthNew > 0){
      EnemyRoll <- rbinom(1,1,E.hitprob)
      if(EnemyRoll == 1){
        HealthNew <- HealthNew - sample(1:E.HitMax,1)
        tickL <- tickL + 1
      } else if(EnemyRoll == 0){
        tickL <- tickL + 1
      }
      if(HealthNew < Health - HealingAmount & HealingQuantityNew > 0){ # This system currently does not allow 2 eats per attack; fix this later
        HealthNew <- HealthNew + HealingAmount
        HealingQuantityNew <- HealingQuantityNew - 1
        FtickW <- FtickW + 1
      }
      tickL <- tickL + E.AttackSpeed - 1
    }
    tickW <- rawtickW + FtickW
    if(tickW < tickL){
      Win <- Win + 1
      fights <- fights + 1
    } else if(tickW > tickL){
      fights <- fights + 1
    }
  }
  print(Win)
  WinProbability <- Win/fights
  print(WinProbability)
}




SimulateFightsV2 <- function(n){
  if(n == 1){
      printhealth <- TRUE
    } else if(n > 1){
      printhealth <- FALSE
    }
  Win <- 0
  fights <- 0
  BattleTimeV <- c()
  HealingUsedV <- c()
  HitsV <- c()
  E.MissV <- c()
  HealthLostV <- c()
  while(n > fights){
    Hits <- 0
    E.Miss <- 0
    tick <- 0
    chargetick <- 0
    E.chargetick <- 0
    HealthNew <- Health
    E.HealthNew <- E.Health
    HealingQuantityNew <- HealingQuantity
    while(E.HealthNew > 0 & HealthNew > 0){
      if(HealthNew < Health - HealingAmount & HealingQuantityNew > 0){
        HealthNew <- HealthNew + HealingAmount
        HealingQuantityNew <- HealingQuantityNew - 1
        if(printhealth == TRUE){
          print(paste0("Your Health : ", HealthNew))
        }
      } else if(chargetick %% AttackSpeed == 0){
        PlayerRoll <- rbinom(1,1,hitprob)
        if(PlayerRoll == 1){
          PlayerDamage <- sample(HitMin:HitMax,1)
          E.HealthNew <- E.HealthNew - PlayerDamage
          if(PlayerDamage > 0){
            Hits <- Hits + 1
          }
          if(printhealth == TRUE){
            print(paste0("Enemy Health : ", E.HealthNew))
          }
        }
        chargetick <- chargetick + 1
      } else if(chargetick %% AttackSpeed != 0){
        chargetick <- chargetick + 1
        if(printhealth == TRUE){
          print(paste0("Enemy Health : ", E.HealthNew))
        }
      }
      if(E.chargetick %% E.AttackSpeed == 0){
        E.chargetick <- E.chargetick + 1
        EnemyRoll <- rbinom(1,1,E.hitprob)
        if(EnemyRoll == 1){
          HealthNew <- HealthNew - sample(1:E.HitMax,1)
          if(printhealth == TRUE){
            print(paste0("Your Health : ", HealthNew))
          }
        } else if(EnemyRoll == 0){
          E.Miss <- E.Miss + 1
        }
      } else if(E.chargetick %% E.AttackSpeed != 0){
        E.chargetick <- E.chargetick + 1
        if(printhealth == TRUE){
          print(paste0("Your Health : ", HealthNew))
        }
      }
      if(Toxic == T) {
        if(tick %% 10 == 0) {
          HealthNew <- HealthNew - 5
        }
      }
      tick <- tick + 1
      if(E.HealthNew <= 0){
        Win <- Win + 1
        fights <- fights + 1
      } else if(HealthNew <= 0){
        fights <- fights + 1
      }
      if(E.HealthNew <= 0 | HealthNew <= 0){
        HealingUsedV[fights] <- HealingQuantity - HealingQuantityNew
        BattleTimeV[fights] <- tick/2
        HitsV[fights] <- Hits
        E.MissV[fights] <- E.Miss
        HealthLostV[fights] <- (HealingQuantity - HealingQuantityNew)*HealingAmount + (Health - HealthNew)
      }
    }
  }
  HealingUsedLower <- round(mean(HealingUsedV)-qnorm(0.9995)*sd(HealingUsedV)/sqrt(n),digits = 4)
  HealingUsedUpper <- round(mean(HealingUsedV)+qnorm(0.9995)*sd(HealingUsedV)/sqrt(n),digits = 4)
  if(E.CombatLevel > 0 & E.CombatLevel < 33){
    if(E.CombatLevel < 9){
      AvgDefXP <- mean(E.MissV)*ceiling(E.CombatLevel/8)
    } else if(Combat >= 9){
      AvgDefXP <- mean(E.MissV)*floor(E.CombatLevel/8)
    }
    if(E.CombatLevel < 17){
      AvgAccXP <- mean(HitsV)*ceiling(E.CombatLevel/16)
    } else if(E.CombatLevel >= 17) {
      AvgAccXP <- mean(HitsV)*floor(E.CombatLevel/16)
    }
    AvgHealthXP <- mean(HealthLostV)*ceiling(E.CombatLevel/32)
    print(paste0("Average Defense XP : ", AvgDefXP, " XP"))
    print(paste0("Average Accuracy XP : ", AvgAccXP, " XP"))
    print(paste0("Average Health XP : ", AvgHealthXP, " XP"))
  } else if(E.CombatLevel >= 33){
    AvgAccXP <- mean(HitsV)*floor(E.CombatLevel/16)
    AvgDefXP <- mean(E.MissV)*floor(E.CombatLevel/8)
    AvgHealthXP <- mean(HealthLostV)*floor(E.CombatLevel/32)
    print(paste0("Average Defense XP : ", AvgDefXP, " XP"))
    print(paste0("Average Accuracy XP : ", AvgAccXP, " XP"))
    print(paste0("Average Health XP : ", AvgHealthXP, " XP"))
  }
  print(paste0("Average Healing Used : ",mean(HealingUsedV)))
  print(paste0("Standard Deviation of Healing Used : ",sd(HealingUsedV)))
  print(paste0("99.9% Confidence Interval for Food Used : (", HealingUsedLower, ", ", HealingUsedUpper, ")"))
  print(paste0("Average Battle Length : ", mean(BattleTimeV), " s"))
  print(paste0("Battles Won : ",Win))
  WinProbability <- Win/fights
  print(paste0("Running Probability of Winning : ",WinProbability))
  binom.test(n*WinProbability,n,WinProbability,conf.level = 0.999)
}

# ______________________________________________________________________________________________________________________

# Fight Simulator

#n <- 10000
#m <- SimulateFights(n)
#binom.test(n*m,n,m,conf.level = 0.999)

# Fight Simulator V2

SimulateFightsV2(10000)
