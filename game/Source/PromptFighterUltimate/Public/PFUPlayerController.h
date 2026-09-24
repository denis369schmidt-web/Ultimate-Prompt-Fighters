#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "PFUPlayerController.generated.h"

class APFUFighterCharacter;

UCLASS()
class PROMPTFIGHTERULTIMATE_API APFUPlayerController : public APlayerController
{
    GENERATED_BODY()

public:
    APFUPlayerController();
    virtual void SetupInputComponent() override;
    void SetFighters(APFUFighterCharacter* InPlayerOne, APFUFighterCharacter* InPlayerTwo);

private:
    void MoveP1(float Axis);
    void MoveP2(float Axis);
    void P1Standard();
    void P1Special();
    void P2Standard();
    void P2Special();
    void RestartRound();

    UPROPERTY() TObjectPtr<APFUFighterCharacter> PlayerOne;
    UPROPERTY() TObjectPtr<APFUFighterCharacter> PlayerTwo;
};

