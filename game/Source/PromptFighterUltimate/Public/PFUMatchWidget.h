#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "PFUMatchWidget.generated.h"

class UEditableTextBox;
class UTextBlock;
class UProgressBar;

UCLASS()
class PROMPTFIGHTERULTIMATE_API UPFUMatchWidget : public UUserWidget
{
    GENERATED_BODY()

public:
    virtual void NativeConstruct() override;
    void UpdateMatch(float P1Health, float P2Health, float RemainingTime, const FString& Result);

private:
    UFUNCTION() void StartManual();
    UFUNCTION() void StartAutonomous();
    UFUNCTION() void Restart();
    void Start(bool bAutonomous);

    UPROPERTY() TObjectPtr<UEditableTextBox> PlayerOnePrompt;
    UPROPERTY() TObjectPtr<UEditableTextBox> PlayerTwoPrompt;
    UPROPERTY() TObjectPtr<UProgressBar> PlayerOneHealth;
    UPROPERTY() TObjectPtr<UProgressBar> PlayerTwoHealth;
    UPROPERTY() TObjectPtr<UTextBlock> TimerText;
    UPROPERTY() TObjectPtr<UTextBlock> ResultText;
};

