#include "PFUPlayerController.h"

#include "PFUFighterCharacter.h"
#include "PFUMatchGameMode.h"

APFUPlayerController::APFUPlayerController()
{
    bShowMouseCursor = true;
    bEnableClickEvents = true;
}

void APFUPlayerController::SetupInputComponent()
{
    Super::SetupInputComponent();
    InputComponent->BindAxis(TEXT("P1Move"), this, &APFUPlayerController::MoveP1);
    InputComponent->BindAxis(TEXT("P2Move"), this, &APFUPlayerController::MoveP2);
    InputComponent->BindAction(TEXT("P1Standard"), IE_Pressed, this, &APFUPlayerController::P1Standard);
    InputComponent->BindAction(TEXT("P1Special"), IE_Pressed, this, &APFUPlayerController::P1Special);
    InputComponent->BindAction(TEXT("P2Standard"), IE_Pressed, this, &APFUPlayerController::P2Standard);
    InputComponent->BindAction(TEXT("P2Special"), IE_Pressed, this, &APFUPlayerController::P2Special);
    InputComponent->BindAction(TEXT("RestartRound"), IE_Pressed, this, &APFUPlayerController::RestartRound);
}

void APFUPlayerController::SetFighters(APFUFighterCharacter* InPlayerOne, APFUFighterCharacter* InPlayerTwo)
{
    PlayerOne = InPlayerOne;
    PlayerTwo = InPlayerTwo;
}

void APFUPlayerController::MoveP1(float Axis) { if (PlayerOne) PlayerOne->MoveHorizontal(Axis); }
void APFUPlayerController::MoveP2(float Axis) { if (PlayerTwo) PlayerTwo->MoveHorizontal(Axis); }
void APFUPlayerController::P1Standard() { if (PlayerOne) PlayerOne->StandardAttack(); }
void APFUPlayerController::P1Special() { if (PlayerOne) PlayerOne->SpecialAttack(); }
void APFUPlayerController::P2Standard() { if (PlayerTwo) PlayerTwo->StandardAttack(); }
void APFUPlayerController::P2Special() { if (PlayerTwo) PlayerTwo->SpecialAttack(); }
void APFUPlayerController::RestartRound()
{
    if (APFUMatchGameMode* Match = GetWorld()->GetAuthGameMode<APFUMatchGameMode>()) Match->RestartCurrentMatch();
}

